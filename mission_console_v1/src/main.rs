use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use anyhow::{anyhow, Context, Result};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::{
    fs,
    io::Write,
    path::{Path as FsPath, PathBuf},
    sync::Arc,
};
use time::{format_description::well_known::Rfc3339, OffsetDateTime};
use tower_http::cors::CorsLayer;
use uuid::Uuid;
use walkdir::WalkDir;

#[derive(Debug, Serialize, Deserialize, Clone)]
struct AppState {
    root: PathBuf,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct MissionSummary {
    mission_id: Uuid,
    name: String,
    created_at: String,
    last_snapshot_id: Option<Uuid>,
    last_snapshot_at: Option<String>,
    snapshot_status: String, // "NONE" | "LOCKED"
    data_count: u64,
    last_report_at: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct MissionMeta {
    mission_id: Uuid,
    name: String,
    created_at: String,
}



#[derive(Debug, Serialize, Deserialize, Clone)]
struct SnapshotMeta {
    snapshot_id: Uuid,
    mission_id: Uuid,
    locked_at: String,
    manifest_sha256: String,
    file_count: u64,
    total_bytes: u64,
    #[serde(default)]
    prev_snapshot_id: Option<Uuid>,
    #[serde(default)]
    prev_chain_sha256: Option<String>,
    #[serde(default)]
    chain_sha256: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct CreateMissionReq {
    name: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct CreateMissionResp {
    mission_id: Uuid,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct ImportReq {
    // base64 is intentionally not supported in V1 to keep determinism simple.
    // Provide server-side file path to import from (local only).
    local_path: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct ImportResp {
    imported_files: u64,
    imported_bytes: u64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct LockSnapshotResp {
    snapshot_id: Uuid,
    manifest_sha256: String,
    file_count: u64,
    total_bytes: u64,
}

fn now_rfc3339() -> String {
    OffsetDateTime::now_utc().format(&Rfc3339).unwrap()
}

fn ensure_dir(p: &FsPath) -> Result<()> {
    fs::create_dir_all(p).with_context(|| format!("create_dir_all {:?}", p))?;
    Ok(())
}

fn write_json_atomic<T: Serialize>(path: &FsPath, value: &T) -> Result<()> {
    let tmp = path.with_extension("tmp");
    let data = serde_json::to_vec_pretty(value)?;
    {
        let mut f = fs::File::create(&tmp)?;
        f.write_all(&data)?;
        f.sync_all()?;
    }
    fs::rename(&tmp, path)?;
    Ok(())
}

fn read_json<T: for<'de> Deserialize<'de>>(path: &FsPath) -> Result<T> {
    let data = fs::read(path)?;
    Ok(serde_json::from_slice(&data)?)
}

fn mission_dir(root: &FsPath, mission_id: Uuid) -> PathBuf {
    root.join("missions").join(mission_id.to_string())
}

fn mission_meta_path(root: &FsPath, mission_id: Uuid) -> PathBuf {
    mission_dir(root, mission_id).join("meta.json")
}

fn mission_log_path(root: &FsPath, mission_id: Uuid) -> PathBuf {
    mission_dir(root, mission_id).join("log.jsonl")
}

fn vault_dir(root: &FsPath, mission_id: Uuid) -> PathBuf {
    mission_dir(root, mission_id).join("vault").join("working")
}

fn snapshots_dir(root: &FsPath, mission_id: Uuid) -> PathBuf {
    mission_dir(root, mission_id).join("snapshots")
}

fn reports_dir(root: &FsPath, mission_id: Uuid) -> PathBuf {
    mission_dir(root, mission_id).join("reports")
}

fn locked_marker(root: &FsPath, mission_id: Uuid) -> PathBuf {
    mission_dir(root, mission_id).join("vault").join("LOCKED.json")
}

fn is_locked(root: &FsPath, mission_id: Uuid) -> bool {
    locked_marker(root, mission_id).exists()
}

// Deterministic hash of a manifest JSON string (stable ordering is ensured by our sorted listing)
fn sha256_hex(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    hex::encode(hasher.finalize())
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct ManifestEntry {
    rel_path: String,
    sha256: String,
    bytes: u64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct Manifest {
    mission_id: Uuid,
    snapshot_id: Uuid,
    locked_at: String,
    entries: Vec<ManifestEntry>,
    file_count: u64,
    total_bytes: u64,
}

fn build_manifest(vault_working: &FsPath, mission_id: Uuid, snapshot_id: Uuid, locked_at: &str) -> Result<Manifest> {
    let mut entries: Vec<ManifestEntry> = vec![];
    let mut total_bytes: u64 = 0;

    let mut files: Vec<PathBuf> = vec![];
    for e in WalkDir::new(vault_working).into_iter().filter_map(|e| e.ok()) {
        if e.file_type().is_file() {
            files.push(e.path().to_path_buf());
        }
    }
    files.sort();

    for fpath in files {
        let data = fs::read(&fpath)?;
        let bytes = data.len() as u64;
        total_bytes = total_bytes.saturating_add(bytes);

        let rel = fpath.strip_prefix(vault_working)
            .map_err(|_| anyhow!("strip_prefix failed"))?
            .to_string_lossy()
            .to_string();

        let file_hash = sha256_hex(&data);

        entries.push(ManifestEntry {
            rel_path: rel,
            sha256: file_hash,
            bytes,
        });
    }

    Ok(Manifest {
        mission_id,
        snapshot_id,
        locked_at: locked_at.to_string(),
        file_count: entries.len() as u64,
        total_bytes,
        entries,
    })
}

async fn health() -> impl IntoResponse {
    (StatusCode::OK, "OK")
}

async fn list_missions(State(st): State<Arc<AppState>>) -> impl IntoResponse {
    let root = &st.root;
    let missions_root = root.join("missions");
    let mut out: Vec<MissionSummary> = vec![];

    if !missions_root.exists() {
        return Json(out);
    }

    let entries = match fs::read_dir(&missions_root) {
        Ok(e) => e,
        Err(_) => return Json(out),
    };

    for entry in entries {
        let e = match entry {
            Ok(v) => v,
            Err(_) => continue,
        };

        let p = e.path();
        if !p.is_dir() {
            continue;
        }

        let mid = match p.file_name()
            .and_then(|s| s.to_str())
            .and_then(|s| Uuid::parse_str(s).ok())
        {
            Some(v) => v,
            None => continue,
        };

        let meta_path = mission_meta_path(root, mid);
        if !meta_path.exists() {
            continue;
        }

        let meta: MissionMeta = match read_json(&meta_path) {
            Ok(v) => v,
            Err(_) => continue,
        };

        let vault_working = vault_dir(root, mid);
        let mut data_count = 0u64;

        if vault_working.exists() {
            for w in WalkDir::new(&vault_working).into_iter().filter_map(|x| x.ok()) {
                if w.file_type().is_file() {
                    data_count += 1;
                }
            }
        }

        let sdir = snapshots_dir(root, mid);
        let mut last_snapshot_id: Option<Uuid> = None;
        let mut last_snapshot_at: Option<String> = None;

        if sdir.exists() {
            let mut snaps: Vec<PathBuf> = match fs::read_dir(&sdir) {
                Ok(rd) => rd.filter_map(|x| x.ok().map(|y| y.path())).collect(),
                Err(_) => vec![],
            };

            snaps.retain(|p| p.is_dir());
            snaps.sort();

            if let Some(last) = snaps.last() {
                if let Some(sid) = last.file_name()
                    .and_then(|s| s.to_str())
                    .and_then(|s| Uuid::parse_str(s).ok())
                {
                    last_snapshot_id = Some(sid);

                    let snap_meta_path = last.join("snapshot.json");
                    if snap_meta_path.exists() {
                        if let Ok(sm) = read_json::<SnapshotMeta>(&snap_meta_path) {
                            last_snapshot_at = Some(sm.locked_at);
                        }
                    }
                }
            }
        }

        let snapshot_status = if last_snapshot_id.is_some() {
            "LOCKED".to_string()
        } else {
            "NONE".to_string()
        };

        out.push(MissionSummary {
            mission_id: meta.mission_id,
            name: meta.name,
            created_at: meta.created_at,
            last_snapshot_id,
            last_snapshot_at,
            snapshot_status,
            data_count,
            last_report_at: None,
        });
    }

    Json(out)
}

async fn create_mission(State(st): State<Arc<AppState>>, Json(req): Json<CreateMissionReq>) -> impl IntoResponse {
    let root = &st.root;
    let mission_id = Uuid::new_v4();
    let mdir = mission_dir(root, mission_id);

    if let Err(e) = ensure_dir(&mdir) {
        return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
    }
    let _ = ensure_dir(&vault_dir(root, mission_id));
    let _ = ensure_dir(&snapshots_dir(root, mission_id));
    let _ = ensure_dir(&reports_dir(root, mission_id));

    let meta = MissionMeta {
        mission_id,
        name: req.name,
        created_at: now_rfc3339(),
    };

    if let Err(e) = write_json_atomic(&mission_meta_path(root, mission_id), &meta) {
        return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
    }

    // log append
    let log_line = serde_json::json!({
        "ts": now_rfc3339(),
        "event": "MISSION_CREATED",
        "mission_id": mission_id,
    });
    let lp = mission_log_path(root, mission_id);
    if let Ok(mut f) = fs::OpenOptions::new().create(true).append(true).open(&lp) {
        let _ = writeln!(f, "{}", log_line);
        let _ = f.sync_all();
    }

    Json(CreateMissionResp { mission_id }).into_response()
}

async fn import_to_vault(
    State(st): State<Arc<AppState>>,
    Path(mission_id): Path<Uuid>,
    Json(req): Json<ImportReq>,
) -> impl IntoResponse {
    let root = &st.root;

    if is_locked(root, mission_id) {
        return (StatusCode::CONFLICT, "VAULT_LOCKED").into_response();
    }

    let src = PathBuf::from(req.local_path);
    if !src.exists() {
        return (StatusCode::BAD_REQUEST, "SOURCE_NOT_FOUND").into_response();
    }

    let dest_root = vault_dir(root, mission_id);
    if let Err(e) = ensure_dir(&dest_root) {
        return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
    }

    let mut imported_files: u64 = 0;
    let mut imported_bytes: u64 = 0;

    if src.is_file() {
        // copy file into vault root
        let fname = src.file_name().and_then(|s| s.to_str()).unwrap_or("file.bin");
        let dest = dest_root.join(fname);
        match fs::read(&src) {
            Ok(data) => {
                imported_bytes += data.len() as u64;
                if fs::write(&dest, &data).is_ok() {
                    imported_files += 1;
                }
            }
            Err(_) => return (StatusCode::BAD_REQUEST, "SOURCE_READ_FAILED").into_response(),
        }
    } else {
        // copy directory recursively
        for e in WalkDir::new(&src).into_iter().filter_map(|e| e.ok()) {
            if e.file_type().is_dir() { continue; }
            let p = e.path().to_path_buf();
            let rel = match p.strip_prefix(&src) {
                Ok(r) => r,
                Err(_) => continue,
            };
            let dest = dest_root.join(rel);
            if let Some(parent) = dest.parent() {
                let _ = ensure_dir(parent);
            }
            match fs::read(&p) {
                Ok(data) => {
                    imported_bytes += data.len() as u64;
                    if fs::write(&dest, &data).is_ok() {
                        imported_files += 1;
                    }
                }
                Err(_) => {}
            }
        }
    }

    Json(ImportResp { imported_files, imported_bytes }).into_response()
}

async fn lock_snapshot(
    State(st): State<Arc<AppState>>,
    Path(mission_id): Path<Uuid>,
) -> impl IntoResponse {
    let root = &st.root;

    if is_locked(root, mission_id) {
        return (StatusCode::CONFLICT, "ALREADY_LOCKED").into_response();
    }

    let vault_working = vault_dir(root, mission_id);
    if !vault_working.exists() {
        return (StatusCode::BAD_REQUEST, "NO_VAULT_DATA").into_response();
    }

    let snapshot_id = Uuid::new_v4();
    let locked_at = now_rfc3339();

    // Build manifest from working vault
    let manifest = match build_manifest(&vault_working, mission_id, snapshot_id, &locked_at) {
        Ok(m) => m,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response(),
    };
    let manifest_json = match serde_json::to_vec_pretty(&manifest) {
        Ok(v) => v,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response(),
    };
    let manifest_sha256 = sha256_hex(&manifest_json);

    // Create snapshot dir and copy vault working into it (immutable evidence)
    let sdir = snapshots_dir(root, mission_id).join(snapshot_id.to_string());
    if let Err(e) = ensure_dir(&sdir) {
        return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
    }
    let snap_vault = sdir.join("vault");
    let _ = ensure_dir(&snap_vault);

    // Copy files deterministically (sorted traversal)
    let mut files: Vec<PathBuf> = vec![];
    for e in WalkDir::new(&vault_working).into_iter().filter_map(|e| e.ok()) {
        if e.file_type().is_file() {
            files.push(e.path().to_path_buf());
        }
    }
    files.sort();

    for f in files {
        let rel = match f.strip_prefix(&vault_working) {
            Ok(r) => r,
            Err(_) => continue,
        };
        let dest = snap_vault.join(rel);
        if let Some(parent) = dest.parent() {
            let _ = ensure_dir(parent);
        }
        if let Ok(data) = fs::read(&f) {
            let _ = fs::write(&dest, data);
        }
    }

    // Write manifest into snapshot
    let manifest_path = sdir.join("manifest.json");
    if let Err(e) = fs::write(&manifest_path, &manifest_json) {
        return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
    }

    // Write snapshot meta


    // ----- CHAIN FIELDS (V1 minimal, deterministic) -----
    let _prev_snapshot_id: Option<Uuid> = None;
    let chain_seed: String = "GENESIS".to_string();
    let chain_input = format!("{}:{}", chain_seed, manifest_sha256);
    let chain_sha256 = sha256_hex(chain_input.as_bytes());

    // ----- DETERMINISTIC PER-MISSION CHAIN -----
    let mut prev_snapshot_id: Option<Uuid> = None;
    let mut prev_chain_sha256: Option<String> = None;
    let sdir = snapshots_dir(&st.root, mission_id);
    if let Ok(entries) = std::fs::read_dir(&sdir) {
        let mut snaps: Vec<_> = entries.filter_map(|e| e.ok().map(|x| x.path())).collect();
        snaps.retain(|p| p.is_dir());
        snaps.sort();
        if let Some(last) = snaps.last() {
            let meta_path = last.join("snapshot.json");
            if meta_path.exists() {
                if let Ok(prev_meta) = read_json::<SnapshotMeta>(&meta_path) {
                    prev_snapshot_id = Some(prev_meta.snapshot_id);
                    prev_chain_sha256 = prev_meta.chain_sha256.clone().or(Some(prev_meta.manifest_sha256.clone()));
                }
            }
        }
    }
    let chain_seed = prev_chain_sha256.clone().unwrap_or_else(|| "GENESIS".to_string());
    let chain_input = format!("{}:{}", chain_seed, manifest_sha256);
    let chain_sha256 = sha256_hex(chain_input.as_bytes());
    let snapshot_meta = SnapshotMeta {
        snapshot_id,
        mission_id,
        locked_at: locked_at.clone(),
        manifest_sha256: manifest_sha256.clone(),
        file_count: manifest.file_count,
        total_bytes: manifest.total_bytes,
        prev_snapshot_id: prev_snapshot_id,
        prev_chain_sha256: Some(chain_seed),
        chain_sha256: Some(chain_sha256.clone()),
    };
    if let Err(e) = write_json_atomic(&sdir.join("snapshot.json"), &snapshot_meta) {
        return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
    }

    // Create lock marker (enforces "no mutation after lock" for V1)
    let lock_marker_payload = serde_json::json!({
        "mission_id": mission_id,
        "snapshot_id": snapshot_id,
        "locked_at": locked_at,
        "manifest_sha256": manifest_sha256,
    });
    if let Err(e) = write_json_atomic(&locked_marker(root, mission_id), &lock_marker_payload) {
        return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
    }

    Json(LockSnapshotResp {
        snapshot_id,
        manifest_sha256,
        file_count: manifest.file_count,
        total_bytes: manifest.total_bytes,
    }).into_response()
}

#[tokio::main]
async fn main() -> Result<()> {
    let root = std::env::var("MISSION_CONSOLE_ROOT").unwrap_or_else(|_| {
        let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
        format!("{home}/.amethyst_mission_console_v1")
    });

    let root = PathBuf::from(root);
    ensure_dir(&root)?;
    ensure_dir(&root.join("missions"))?;

    let state = Arc::new(AppState { root });

    let app = Router::new()
        .route("/health", get(health))
        .route("/api/missions", get(list_missions).post(create_mission))
        .route("/api/missions/:mission_id/vault/import", post(import_to_vault))
        .route("/api/missions/:mission_id/snapshot/lock", post(lock_snapshot))
        .route("/api/missions/:mission_id/insights", get(mission_insights))
        .route("/api/missions/:mission_id/export/proof_bundle", post(export_proof_bundle))
        .route("/api/missions/:mission_id/export/verify_bundle", get(verify_proof_bundle))
        .route("/api/missions/:mission_id/export/proof_bundle_zip", post(export_proof_bundle_zip))
        .layer(CorsLayer::permissive())
        .with_state(state);

    let addr = "127.0.0.1:7765";
    let listener = tokio::net::TcpListener::bind(addr).await?;
    println!("MISSION_CONSOLE_V1 listening on http://{addr}");
    axum::serve(listener, app).await?;
    Ok(())
}

// =======================
// INSIGHTS
// =======================

#[derive(Debug, Serialize, Deserialize, Clone)]
struct MissionInsights {
    mission_id: Uuid,
    snapshot_id: Uuid,
    locked_at: String,
    manifest_sha256: String,
    file_count: u64,
    total_bytes: u64,
    snapshot_path: String,
}

async fn mission_insights(
    State(st): State<Arc<AppState>>,
    Path(mission_id): Path<Uuid>,
) -> impl IntoResponse {
    let root = &st.root;

    let sdir = snapshots_dir(root, mission_id);
    if !sdir.exists() {
        return (StatusCode::NOT_FOUND, "NO_SNAPSHOTS").into_response();
    }

    let mut snaps: Vec<PathBuf> =
        fs::read_dir(&sdir)
            .unwrap()
            .filter_map(|x| x.ok().map(|y| y.path()))
            .collect();

    snaps.retain(|p| p.is_dir());
    snaps.sort();

    let last = snaps.last().unwrap();

    let snapshot_meta: SnapshotMeta =
        read_json(&last.join("snapshot.json")).unwrap();

    Json(MissionInsights {
        mission_id,
        snapshot_id: snapshot_meta.snapshot_id,
        locked_at: snapshot_meta.locked_at,
        manifest_sha256: snapshot_meta.manifest_sha256,
        file_count: snapshot_meta.file_count,
        total_bytes: snapshot_meta.total_bytes,
        snapshot_path: last.to_string_lossy().to_string(),
    }).into_response()
}

// =======================
// PROOF BUNDLE EXPORT
// =======================

#[derive(Debug, Serialize, Deserialize, Clone)]
struct ProofBundleReceipt {
    mission_id: Uuid,
    snapshot_id: Uuid,
    manifest_sha256: String,
    bundle_sha256: String,
    file_count: u64,
    total_bytes: u64,
    export_path: String,
    exported_at: String,
}

fn exports_dir(root: &FsPath, mission_id: Uuid) -> PathBuf {
    mission_dir(root, mission_id).join("exports")
}

async fn export_proof_bundle(
    State(st): State<Arc<AppState>>,
    Path(mission_id): Path<Uuid>,
) -> impl IntoResponse {
    let root = &st.root;

    let sdir = snapshots_dir(root, mission_id);
    let mut snaps: Vec<PathBuf> =
        fs::read_dir(&sdir)
            .unwrap()
            .filter_map(|x| x.ok().map(|y| y.path()))
            .collect();

    snaps.sort();
    let last = snaps.last().unwrap();

    let snapshot_meta: SnapshotMeta =
        read_json(&last.join("snapshot.json")).unwrap();

    let manifest_bytes = fs::read(&last.join("manifest.json")).unwrap();
    let snapshot_bytes = fs::read(&last.join("snapshot.json")).unwrap();

    let mut concat = Vec::new();
    concat.extend_from_slice(&manifest_bytes);
    concat.extend_from_slice(&snapshot_bytes);

    let bundle_sha256 = sha256_hex(&concat);

    let export_root = exports_dir(root, mission_id);
    ensure_dir(&export_root).unwrap();

    let export_dir = export_root.join(snapshot_meta.snapshot_id.to_string());
    ensure_dir(&export_dir).unwrap();

    fs::copy(last.join("manifest.json"), export_dir.join("manifest.json")).unwrap();
    fs::copy(last.join("snapshot.json"), export_dir.join("snapshot.json")).unwrap();

    let receipt = ProofBundleReceipt {
        mission_id,
        snapshot_id: snapshot_meta.snapshot_id,
        manifest_sha256: snapshot_meta.manifest_sha256,
        bundle_sha256,
        file_count: snapshot_meta.file_count,
        total_bytes: snapshot_meta.total_bytes,
        export_path: export_dir.to_string_lossy().to_string(),
        exported_at: now_rfc3339(),
    };

    write_json_atomic(&export_dir.join("proof.json"), &receipt).unwrap();

    Json(receipt)
}

async fn verify_proof_bundle(
    State(st): State<Arc<AppState>>,
    Path(mission_id): Path<Uuid>,
) -> impl IntoResponse {
    let root = &st.root;
    let export_root = exports_dir(root, mission_id);

    let mut exports: Vec<PathBuf> =
        fs::read_dir(&export_root)
            .unwrap()
            .filter_map(|x| x.ok().map(|y| y.path()))
            .collect();

    exports.sort();
    let last = exports.last().unwrap();

    let proof: ProofBundleReceipt =
        read_json(&last.join("proof.json")).unwrap();

    let manifest_bytes = fs::read(last.join("manifest.json")).unwrap();
    let snapshot_bytes = fs::read(last.join("snapshot.json")).unwrap();

    let mut concat = Vec::new();
    concat.extend_from_slice(&manifest_bytes);
    concat.extend_from_slice(&snapshot_bytes);

    let recomputed = sha256_hex(&concat);

    Json(serde_json::json!({
        "verified": recomputed == proof.bundle_sha256,
        "expected": proof.bundle_sha256,
        "recomputed": recomputed
    }))
}

// ZIP export intentionally omitted for now to restore system stability.


// =======================
// PROOF BUNDLE ZIP EXPORT
// =======================

#[derive(Debug, Serialize, Deserialize, Clone)]
struct ZipExportReceipt {
    mission_id: Uuid,
    snapshot_id: Uuid,
    archive_path: String,
    archive_sha256: String,
    exported_at: String,
}

async fn export_proof_bundle_zip(
    State(st): State<Arc<AppState>>,
    Path(mission_id): Path<Uuid>,
) -> impl IntoResponse {
    use zip::write::FileOptions;
    use zip::ZipWriter;

    let root = &st.root;
    let export_root = exports_dir(root, mission_id);

    if !export_root.exists() {
        return (StatusCode::NOT_FOUND, "NO_EXPORTS").into_response();
    }

    let mut exports: Vec<PathBuf> =
        fs::read_dir(&export_root)
            .unwrap()
            .filter_map(|x| x.ok().map(|y| y.path()))
            .collect();

    exports.retain(|p| p.is_dir());
    exports.sort();

    let last = exports.last().unwrap();

    let proof: ProofBundleReceipt =
        read_json(&last.join("proof.json")).unwrap();

    let archive_path = last.join("bundle.zip");

    if archive_path.exists() {
        return (StatusCode::CONFLICT, "ZIP_ALREADY_EXISTS").into_response();
    }

    let file = fs::File::create(&archive_path).unwrap();
    let mut zip = ZipWriter::new(file);
    let options = FileOptions::default();

    for entry in fs::read_dir(last).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();
        if path.is_file() {
            let name = path.file_name().unwrap().to_string_lossy();
            zip.start_file(name, options).unwrap();
            let data = fs::read(&path).unwrap();
            use std::io::Write;
            zip.write_all(&data).unwrap();
        }
    }

    zip.finish().unwrap();

    let zip_bytes = fs::read(&archive_path).unwrap();
    let archive_sha256 = sha256_hex(&zip_bytes);

    Json(ZipExportReceipt {
        mission_id,
        snapshot_id: proof.snapshot_id,
        archive_path: archive_path.to_string_lossy().to_string(),
        archive_sha256,
        exported_at: now_rfc3339(),
    }).into_response()
}

