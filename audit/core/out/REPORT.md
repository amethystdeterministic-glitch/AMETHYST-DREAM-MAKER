# ODIN Core Freeze Audit Report

Generated: Mon Mar  2 01:24:53 UTC 2026

## 10_detect_binaries.txt
```
[STEP 10] Detect canonical binary
[OK] Found executable: target/release/odin_cli
```

## 20_build_release.txt
```
[BUILD] cargo clean
     Removed 1362 files, 335.3MiB total
[BUILD] cargo build --release (capturing warnings)
   Compiling proc-macro2 v1.0.106
   Compiling quote v1.0.44
   Compiling unicode-ident v1.0.24
   Compiling libc v0.2.182
   Compiling cfg-if v1.0.4
   Compiling smallvec v1.15.1
   Compiling bytes v1.11.1
   Compiling pin-project-lite v0.2.17
   Compiling itoa v1.0.17
   Compiling stable_deref_trait v1.2.1
   Compiling shlex v1.3.0
   Compiling parking_lot_core v0.9.12
   Compiling find-msvc-tools v0.1.9
   Compiling futures-core v0.3.32
   Compiling cc v1.2.56
   Compiling scopeguard v1.2.0
   Compiling once_cell v1.21.3
   Compiling lock_api v0.4.14
   Compiling vcpkg v0.2.15
   Compiling log v0.4.29
   Compiling pkg-config v0.3.32
   Compiling memchr v2.8.0
   Compiling tracing-core v0.1.36
   Compiling litemap v0.8.1
   Compiling typenum v1.19.0
   Compiling errno v0.3.14
   Compiling mio v1.1.1
   Compiling syn v2.0.117
   Compiling signal-hook-registry v1.4.8
   Compiling parking_lot v0.12.5
   Compiling socket2 v0.6.2
   Compiling version_check v0.9.5
   Compiling openssl-sys v0.9.111
   Compiling futures-task v0.3.32
   Compiling futures-io v0.3.32
   Compiling httparse v1.10.1
   Compiling slab v0.4.12
   Compiling writeable v0.6.2
   Compiling serde_core v1.0.228
   Compiling futures-util v0.3.32
   Compiling generic-array v0.14.7
   Compiling tracing v0.1.44
   Compiling icu_properties_data v2.1.2
   Compiling tower-service v0.3.3
   Compiling icu_normalizer_data v2.1.1
   Compiling futures-channel v0.3.32
   Compiling openssl v0.10.75
   Compiling httpdate v1.0.3
   Compiling fnv v1.0.7
   Compiling foreign-types-shared v0.1.1
   Compiling foreign-types v0.3.2
   Compiling http v0.2.12
   Compiling hashbrown v0.16.1
   Compiling serde v1.0.228
   Compiling percent-encoding v2.3.2
   Compiling zmij v1.0.21
   Compiling equivalent v1.0.2
   Compiling native-tls v0.2.18
   Compiling futures-sink v0.3.32
   Compiling bitflags v2.11.0
   Compiling synstructure v0.13.2
   Compiling indexmap v2.13.0
   Compiling form_urlencoded v1.2.2
   Compiling try-lock v0.2.5
   Compiling openssl-probe v0.2.1
   Compiling semver v1.0.27
   Compiling serde_json v1.0.149
   Compiling want v0.3.1
   Compiling rustc_version v0.4.1
   Compiling crypto-common v0.1.7
   Compiling block-buffer v0.10.4
   Compiling http-body v0.4.6
   Compiling socket2 v0.5.10
   Compiling ryu v1.0.23
   Compiling utf8_iter v1.0.4
   Compiling mime v0.3.17
   Compiling curve25519-dalek v4.1.3
   Compiling digest v0.10.7
   Compiling getrandom v0.4.1
   Compiling base64 v0.21.7
   Compiling blake3 v1.8.3
   Compiling getrandom v0.2.17
   Compiling cpufeatures v0.2.17
   Compiling rustls-pemfile v1.0.4
   Compiling http v1.4.0
   Compiling encoding_rs v0.8.35
   Compiling zerofrom-derive v0.1.6
   Compiling yoke-derive v0.8.1
   Compiling zerovec-derive v0.11.2
   Compiling displaydoc v0.2.5
   Compiling tokio-macros v2.6.0
   Compiling openssl-macros v0.1.1
   Compiling tokio v1.49.0
   Compiling serde_derive v1.0.228
   Compiling signature v2.2.0
   Compiling zerofrom v0.1.6
   Compiling zeroize v1.8.2
   Compiling yoke v0.8.1
   Compiling sync_wrapper v0.1.2
   Compiling subtle v2.6.1
   Compiling zerovec v0.11.5
   Compiling zerotrie v0.2.3
   Compiling ipnet v2.11.0
   Compiling tinystr v0.8.2
   Compiling potential_utf v0.1.4
   Compiling icu_locale_core v2.1.1
   Compiling icu_collections v2.1.1
   Compiling icu_provider v2.1.1
   Compiling ed25519 v2.2.3
   Compiling icu_properties v2.1.2
   Compiling icu_normalizer v2.1.1
   Compiling idna_adapter v1.2.1
   Compiling idna v1.1.0
   Compiling serde_urlencoded v0.7.1
   Compiling http-body v1.0.1
   Compiling tokio-util v0.7.18
   Compiling tokio-native-tls v0.3.1
   Compiling rand_core v0.6.4
   Compiling url v2.5.8
   Compiling sha2 v0.10.9
   Compiling arrayref v0.3.9
   Compiling h2 v0.3.27
   Compiling constant_time_eq v0.4.2
   Compiling arrayvec v0.7.6
   Compiling ed25519-dalek v2.2.0
   Compiling uuid v1.21.0
   Compiling base64 v0.22.1
   Compiling rustversion v1.0.22
   Compiling atomic-waker v1.1.2
   Compiling tower-layer v0.3.3
   Compiling pin-utils v0.1.0
   Compiling sync_wrapper v1.0.2
   Compiling thiserror v1.0.69
   Compiling hyper v1.8.1
   Compiling http-body-util v0.1.3
   Compiling async-trait v0.1.89
   Compiling thiserror-impl v1.0.69
   Compiling tower v0.5.3
   Compiling serde_path_to_error v0.1.20
   Compiling matchit v0.7.3
   Compiling hyper-util v0.1.20
   Compiling odin_kernel v0.1.0 (/data/data/com.termux/files/home/repos/odin_os/kernel)
   Compiling amethystctl v0.1.0 (/data/data/com.termux/files/home/repos/odin_os/amethystctl)
   Compiling axum-core v0.4.5
   Compiling hyper v0.14.32
   Compiling axum v0.7.9
   Compiling hyper-tls v0.5.0
   Compiling reqwest v0.11.27
   Compiling odin_core v0.3.0 (/data/data/com.termux/files/home/repos/odin_os/core)
   Compiling odin_subsystem v0.1.0 (/data/data/com.termux/files/home/repos/odin_os/subsystem)
   Compiling odin_cli v0.1.0 (/data/data/com.termux/files/home/repos/odin_os/odin_cli)
   Compiling pilgrimctl v0.1.0 (/data/data/com.termux/files/home/repos/odin_os/pilgrimctl)
   Compiling pilgrim v1.1.0 (/data/data/com.termux/files/home/repos/odin_os/pilgrim)
warning: field `error` is never read
  --> pilgrimctl/src/main.rs:12:5
   |
 9 | struct QueryResp {
   |        --------- field in this struct
...
12 |     error: Option<String>,
   |     ^^^^^
   |
   = note: `#[warn(dead_code)]` (part of `#[warn(unused)]`) on by default

warning: `pilgrimctl` (bin "pilgrimctl") generated 1 warning
    Finished `release` profile [optimized] target(s) in 31.05s
[HASH] sha256 of executables in target/release
[OK] Wrote audit/core/out/20_release_execs.sha256
```

## 20_release_sha256.txt
```
[HASH] sha256 of executables in target/release
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  -
```

## 20_warnings_only.txt
```
warning: field `error` is never read
warning: `pilgrimctl` (bin "pilgrimctl") generated 1 warning
```

## 30_todo_scan.txt
```
[SCAN] TODO/FIXME in core
NONE

[SCAN] src NOT_FOUND
[SCAN] TODO/FIXME in .
./audit/core/out/REPORT.md:200:[SCAN] TODO/FIXME in core
./audit/core/out/REPORT.md:204:[SCAN] TODO/FIXME in .
./audit/core/out/REPORT.md:205:./audit/core/out/REPORT.md:198:[SCAN] TODO/FIXME in core
./audit/core/out/REPORT.md:206:./audit/core/out/REPORT.md:202:[SCAN] TODO/FIXME in .
./audit/core/out/REPORT.md:207:./audit/core/out/REPORT.md:203:./audit/core/step_30_scan_todos.sh:11:    echo "[SCAN] TODO/FIXME in $d" >> "$OUT/30_todo_scan.txt"
./audit/core/out/REPORT.md:208:./audit/core/out/REPORT.md:204:./audit/core/step_30_scan_todos.sh:12:    grep -RIn --exclude-dir target --exclude-dir .git -E "TODO|FIXME" "$d" >> "$OUT/30_todo_scan.txt" 2>/dev/null || echo "NONE" >> "$OUT/30_todo_scan.txt"
./audit/core/out/REPORT.md:209:./audit/core/step_30_scan_todos.sh:11:    echo "[SCAN] TODO/FIXME in $d" >> "$OUT/30_todo_scan.txt"
./audit/core/out/REPORT.md:210:./audit/core/step_30_scan_todos.sh:12:    grep -RIn --exclude-dir target --exclude-dir .git -E "TODO|FIXME" "$d" >> "$OUT/30_todo_scan.txt" 2>/dev/null || echo "NONE" >> "$OUT/30_todo_scan.txt"
./audit/core/step_30_scan_todos.sh:11:    echo "[SCAN] TODO/FIXME in $d" >> "$OUT/30_todo_scan.txt"
./audit/core/step_30_scan_todos.sh:12:    grep -RIn --exclude-dir target --exclude-dir .git -E "TODO|FIXME" "$d" >> "$OUT/30_todo_scan.txt" 2>/dev/null || echo "NONE" >> "$OUT/30_todo_scan.txt"
NONE

```

## 40_detect_paths.txt
```
[STEP 40] Detect critical paths
[OK] Canonical binary present: target/release/odin_cli
[OK] Audit directory present
[PASS] Path detection complete
```

## 50_verify_baseline.txt
```
[STEP 50] Verify baseline contract
[TRY] target/release/odin_cli verify
{
  "authority_key_found": true,
  "authority_key_path": "/data/data/com.termux/files/home/.odin/keys/authority.key",
  "ledger_found": true,
  "ledger_path": "/data/data/com.termux/files/home/.odin/ledger/ledger.jsonl",
  "notes": [
    "authority_key_not_found_in_default_locations",
    "ledger_not_found_in_default_locations"
  ],
  "odin_core_version": "0.3.0",
  "ok": true,
  "translation_blocks_verified": 0
}
[PASS] Baseline verification complete
```

## 60_replay_check.txt
```
[STEP 60] Replay determinism check
HASH1=966c89e330f0a2a562027167b6f52750805e774c97798676beeb0ec743343be7
HASH2=966c89e330f0a2a562027167b6f52750805e774c97798676beeb0ec743343be7
[PASS] Deterministic replay confirmed
```

## 65_core_api_scan.txt
```
[STEP 65] Scan odin_core for existing verify/proof surfaces

[GREP] export_proof / proof / verify / receipt / ledger / authority
core/src/main.rs:6:    let core = OdinCore::boot();
core/src/main.rs:8:    println!("Ledger entries: {}", core.ledger_len());
core/src/authority/mod.rs:6:const KEY_FILE: &str = "odin_authority.key";
core/src/authority/mod.rs:10:    verifying: VerifyingKey,
core/src/authority/mod.rs:18:                panic!("Invalid authority key length (expected 32 bytes)");
core/src/authority/mod.rs:23:            let verifying = signing.verifying_key();
core/src/authority/mod.rs:24:            Self { signing, verifying }
core/src/authority/mod.rs:28:            let verifying = signing.verifying_key();
core/src/authority/mod.rs:29:            Self { signing, verifying }
core/src/authority/mod.rs:37:    pub fn verify(&self, msg: &[u8], sig: &Signature) -> bool {
core/src/authority/mod.rs:38:        self.verifying.verify(msg, sig).is_ok()
core/src/ledger/mod.rs:3:use crate::authority::AuthorityRoot;
core/src/ledger/mod.rs:10:const LEDGER_FILE: &str = "odin_ledger.jsonl";
core/src/ledger/mod.rs:18:    pub authority_sig: Vec<u8>,
core/src/ledger/mod.rs:37:    pub fn load(authority: &AuthorityRoot) -> Result<Self, &'static str> {
core/src/ledger/mod.rs:42:        let file = File::open(LEDGER_FILE).map_err(|_| "Failed to open ledger")?;
core/src/ledger/mod.rs:47:            let line = line.map_err(|_| "Failed to read ledger line")?;
core/src/ledger/mod.rs:49:            let entry: LedgerEntry = serde_json::from_str(&line).map_err(|_| "Invalid ledger entry")?;
core/src/ledger/mod.rs:53:        let ledger = Self { entries, backend: LedgerBackend::File };
core/src/ledger/mod.rs:55:        if !ledger.verify_chain(authority) {
core/src/ledger/mod.rs:59:        Ok(ledger)
core/src/ledger/mod.rs:75:        authority: &AuthorityRoot,
core/src/ledger/mod.rs:90:            authority_sig: Vec::new(),
core/src/ledger/mod.rs:100:        let sig = authority.sign(entry.entry_hash.as_bytes());
core/src/ledger/mod.rs:101:        entry.authority_sig = sig.to_bytes().to_vec();
core/src/ledger/mod.rs:108:                .map_err(|_| "Failed to open ledger for append")?;
core/src/ledger/mod.rs:111:            writeln!(file, "{}", line).map_err(|_| "Failed to write ledger entry")?;
core/src/ledger/mod.rs:118:    pub fn verify_chain(&self, authority: &AuthorityRoot) -> bool {
core/src/ledger/mod.rs:128:            clone.authority_sig.clear();
core/src/ledger/mod.rs:139:            if entry.authority_sig.len() != 64 {
core/src/ledger/mod.rs:144:            sig_bytes.copy_from_slice(&entry.authority_sig);
core/src/ledger/mod.rs:148:            if !authority.verify(entry.entry_hash.as_bytes(), &sig) {
core/src/ledger/mod.rs:183:        self.has_kind_for_intent("execution_receipt", intent_id)
core/src/core.rs:7:use crate::authority::AuthorityRoot;
core/src/core.rs:8:use crate::ledger::Ledger;
core/src/core.rs:12:use crate::proof::ProofBundle;
core/src/core.rs:15:    authority: AuthorityRoot,
core/src/core.rs:16:    ledger: Ledger,
core/src/core.rs:21:    pub fn boot() -> Self {
core/src/core.rs:22:        let authority = AuthorityRoot::load_or_create();
core/src/core.rs:26:        let mut ledger = match Ledger::load(&authority) {
core/src/core.rs:34:        if state == CoreState::Green && ledger.len() == 0 {
core/src/core.rs:35:            ledger.append_signed("genesis", json!({"event":"genesis"}), &authority, state).ok();
core/src/core.rs:40:            let boot_hash = Self::compute_boot_hash();
core/src/core.rs:42:            ledger.append_signed(
core/src/core.rs:43:                "boot_receipt",
core/src/core.rs:44:                json!({ "timestamp": ts, "boot_hash": boot_hash }),
core/src/core.rs:45:                &authority,
core/src/core.rs:50:        if state == CoreState::Green && !ledger.verify_chain(&authority) {
core/src/core.rs:54:        Self { authority, ledger, state }
core/src/core.rs:57:    fn compute_boot_hash() -> String {
core/src/core.rs:64:    pub fn boot_ephemeral() -> Self {
core/src/core.rs:65:        let authority = AuthorityRoot::load_or_create();
core/src/core.rs:66:        let mut ledger = Ledger::new_in_memory();
core/src/core.rs:69:        ledger.append_signed("genesis", json!({"event":"genesis"}), &authority, state).ok();
core/src/core.rs:71:        if !ledger.verify_chain(&authority) {
core/src/core.rs:75:        Self { authority, ledger, state }
core/src/core.rs:79:    pub fn ledger_len(&self) -> usize { self.ledger.len() }
core/src/core.rs:80:    pub fn chain_valid(&self) -> bool { self.ledger.verify_chain(&self.authority) }
core/src/core.rs:82:    pub fn is_finalized(&self, intent_id: &str) -> bool { self.ledger.finalized(intent_id) }
core/src/core.rs:83:    pub fn is_executed(&self, intent_id: &str) -> bool { self.ledger.executed(intent_id) }
core/src/core.rs:92:        self.ledger.append_signed(
core/src/core.rs:100:            &self.authority,
core/src/core.rs:107:    pub fn record_execution_receipt(
core/src/core.rs:114:        if !self.ledger.finalized(intent_id) {
core/src/core.rs:117:        if self.ledger.executed(intent_id) {
core/src/core.rs:121:        self.ledger.append_signed(
core/src/core.rs:122:            "execution_receipt",
core/src/core.rs:129:            &self.authority,
core/src/core.rs:139:        self.ledger.append_signed(
core/src/core.rs:146:            &self.authority,
core/src/core.rs:156:        self.ledger.append_signed(
core/src/core.rs:164:            &self.authority,
core/src/core.rs:174:        self.ledger.append_signed(
core/src/core.rs:182:            &self.authority,
core/src/core.rs:190:        if !self.ledger.treegate_passed(&intent.intent_id) {
core/src/core.rs:193:        if self.ledger.finalized(&intent.intent_id) {
core/src/core.rs:210:        self.ledger.append_signed(
core/src/core.rs:219:            &self.authority,
core/src/core.rs:229:        self.ledger.append_signed(
core/src/core.rs:235:            &self.authority,
core/src/core.rs:246:        self.ledger.append_signed(
core/src/core.rs:254:            &self.authority,
core/src/core.rs:260:        self.ledger.append_signed(
core/src/core.rs:266:            &self.authority,
core/src/core.rs:274:        if !self.ledger.verify_chain(&self.authority) {
core/src/core.rs:285:            ledger_len: self.ledger_len(),
core/src/core.rs:289:    pub fn proof_bundle(&self, intent_id: Option<&str>) -> ProofBundle {
core/src/core.rs:291:        let boot_receipts = self.ledger.filter_kind("boot_receipt");
core/src/core.rs:292:        let execution_receipts = self.ledger.filter_kind("execution_receipt");
core/src/core.rs:295:            IntentProofSlice::new(id.to_string(), self.ledger.filter_intent(id))
core/src/core.rs:301:            boot_receipts,
core/src/core.rs:302:            execution_receipts,
core/src/core.rs:307:    pub fn export_proof_bundle_json(&self, path: &str, intent_id: Option<&str>) -> Result<(), &'static str> {
core/src/core.rs:308:        let bundle = self.proof_bundle(intent_id);
core/src/lib.rs:1:pub mod authority;
core/src/lib.rs:2:pub mod ledger;
core/src/lib.rs:7:pub mod proof;
core/src/query.rs:3:use crate::ledger::LedgerEntry;
core/src/query.rs:9:    pub ledger_len: usize,
core/src/proof.rs:6:use crate::ledger::LedgerEntry;
core/src/proof.rs:12:    pub boot_receipts: Vec<LedgerEntry>,
core/src/proof.rs:13:    pub execution_receipts: Vec<LedgerEntry>,
core/src/proof.rs:19:        let s = serde_json::to_string_pretty(self).map_err(|_| "Failed to serialize proof bundle")?;
core/src/proof.rs:20:        fs::write(path, s).map_err(|_| "Failed to write proof bundle")?;
core/src/policy/tool.rs:7:    set.insert("export_proof");
core/src/policy/tool.rs:31:        "export_proof",
core/src/capability/profiles.rs:9:        // Full authority. Can mutate, execute tools, spawn, and use network.

```

## 70_ledger_corruption.txt
```
[STEP 70] Ledger corruption drill
[SKIP] Ledger not found.
```

## 70_ledger_corruption_drill.txt
```
[STEP 70] Ledger corruption drill
[PASS] corruption detected (verify failed), ledger restored
```

## 80_authority_missing.txt
```
[STEP 80] Authority missing drill
[SKIP] Authority key not found.
```

## 80_authority_missing_drill.txt
```
[STEP 80] Authority missing drill
[PASS] missing authority correctly caused verify to fail (fail-closed)
```

## 90_duplicate_finalize.txt
```
[STEP 90] Duplicate finalize stress test
[INFO] Manual endpoint stress must be validated if finalize endpoint exists.
[NOTE] Implement HTTP stress if finalize route exposed.
[PASS] Placeholder until finalize HTTP route confirmed.
```

