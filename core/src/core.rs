use crate::router::dispatch::call_brain;
use crate::router::{select_brain, Brain};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::authority::AuthorityRoot;
use crate::ledger::Ledger;
use crate::lifecycle::{Intent, TreeGate, Finalize};
use crate::state::CoreState;
use crate::query::{CoreSnapshot, IntentProofSlice};
use crate::proof::ProofBundle;

pub struct OdinCore {
    authority: AuthorityRoot,
    ledger: Ledger,
    state: CoreState,
}

impl OdinCore {
    pub fn boot() -> Self {
        let authority = AuthorityRoot::load_or_create();

        let mut state = CoreState::Green;

        let mut ledger = match Ledger::load(&authority) {
            Ok(l) => l,
            Err(_) => {
                state = CoreState::Red;
                Ledger::new_in_memory()
            }
        };

        if state == CoreState::Green && ledger.len() == 0 {
            ledger.append_signed("genesis", json!({"event":"genesis"}), &authority, state).ok();
        }

        if state == CoreState::Green {
            let ts = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
            let boot_hash = Self::compute_boot_hash();

            ledger.append_signed(
                "boot_receipt",
                json!({ "timestamp": ts, "boot_hash": boot_hash }),
                &authority,
                state
            ).ok();
        }

        if state == CoreState::Green && !ledger.verify_chain(&authority) {
            state = CoreState::Red;
        }

        Self { authority, ledger, state }
    }

    fn compute_boot_hash() -> String {
        let mut hasher = Sha256::new();
        hasher.update(env!("CARGO_PKG_VERSION"));
        hasher.update(std::env::consts::OS);
        format!("{:x}", hasher.finalize())
    }

    pub fn boot_ephemeral() -> Self {
        let authority = AuthorityRoot::load_or_create();
        let mut ledger = Ledger::new_in_memory();
        let mut state = CoreState::Green;

        ledger.append_signed("genesis", json!({"event":"genesis"}), &authority, state).ok();

        if !ledger.verify_chain(&authority) {
            state = CoreState::Red;
        }

        Self { authority, ledger, state }
    }

    pub fn state(&self) -> CoreState { self.state }
    pub fn ledger_len(&self) -> usize { self.ledger.len() }
    pub fn chain_valid(&self) -> bool { self.ledger.verify_chain(&self.authority) }

    pub fn is_finalized(&self, intent_id: &str) -> bool { self.ledger.finalized(intent_id) }
    pub fn is_executed(&self, intent_id: &str) -> bool { self.ledger.executed(intent_id) }

    pub fn record_brain_event(
        &mut self,
        brain_name: &str,
        input_hash: &str,
        output_hash: &str,
        output_text: &str,
    ) -> Result<(), &'static str> {
        self.ledger.append_signed(
            "brain_event",
            json!({
                "brain_name": brain_name,
                "input_hash": input_hash,
                "output_hash": output_hash,
                "output_text": output_text
            }),
            &self.authority,
            self.state
        )?;
        self.refresh_state();
        Ok(())
    }

    pub fn record_execution_receipt(
        &mut self,
        intent_id: &str,
        tool_name: &str,
        args: serde_json::Value,
        output_hash: &str,
    ) -> Result<(), &'static str> {
        if !self.ledger.finalized(intent_id) {
            return Err("Execution blocked: intent not finalized");
        }
        if self.ledger.executed(intent_id) {
            return Err("Execution blocked: already executed (single-shot)");
        }

        self.ledger.append_signed(
            "execution_receipt",
            json!({
                "intent_id": intent_id,
                "tool_name": tool_name,
                "args": args,
                "output_hash": output_hash
            }),
            &self.authority,
            self.state
        )?;
        self.refresh_state();
        Ok(())
    }

    pub fn submit_intent(&mut self, request: String) -> Result<Intent, &'static str> {
        let intent = Intent::new(request);

        self.ledger.append_signed(
            "intent",
            json!({
                "intent_id": intent.intent_id,
                "intent_hash": intent.intent_hash,
                "request": intent.request
            }),
            &self.authority,
            self.state
        )?;
        self.refresh_state();
        Ok(intent)
    }

    pub fn tree_gate_pass(&mut self, intent: &Intent) -> Result<TreeGate, &'static str> {
        let gate = TreeGate::pass(intent);

        self.ledger.append_signed(
            "tree_gate",
            json!({
                "intent_id": gate.intent_id,
                "intent_hash": gate.intent_hash,
                "pass": gate.pass,
                "reason": gate.reason
            }),
            &self.authority,
            self.state
        )?;
        self.refresh_state();
        Ok(gate)
    }

    pub fn tree_gate_fail(&mut self, intent: &Intent, reason: &str) -> Result<TreeGate, &'static str> {
        let gate = TreeGate::fail(intent, reason);

        self.ledger.append_signed(
            "tree_gate",
            json!({
                "intent_id": gate.intent_id,
                "intent_hash": gate.intent_hash,
                "pass": gate.pass,
                "reason": gate.reason
            }),
            &self.authority,
            self.state
        )?;
        self.refresh_state();
        Ok(gate)
    }

    pub fn finalize(&mut self, intent: &Intent) -> Result<Finalize, &'static str> {
        if !self.ledger.treegate_passed(&intent.intent_id) {
            return Err("Finalize blocked: TreeGate not PASS");
        }
        if self.ledger.finalized(&intent.intent_id) {
            return Err("Finalize blocked: already finalized (single-shot)");
        }

        // ---- Stage 13: Capability-Governed TreeGate ----
        let tg_input = crate::lifecycle::tree_gate::TreeGateInput {
            tool_name: &intent.request, // using request as tool placeholder
            target_path: "",            // placeholder until Intent extended
            port: 0,                    // placeholder until Intent extended
            role: crate::policy::role::Role::Sovereign,
        };

        let audit = match crate::lifecycle::tree_gate::validate_tree_gate(&tg_input) {
            Ok(a) => a,
            Err(_) => return Err("Finalize blocked: Capability enforcement failed"),
        };

        self.ledger.append_signed(
            "cap_audit",
            json!({
                "intent_id": intent.intent_id,
                "tool": audit.tool,
                "role": format!("{:?}", audit.role),
                "derived": audit.derived,
                "required": audit.required
            }),
            &self.authority,
            self.state
        )?;

        // ---- Stage 14: Deterministic Brain Selection ----
        let selected_brain = select_brain(&intent.request);
        let brain_str = match selected_brain {
            Brain::Qwen => "qwen",
            Brain::QwenCoder => "qwen_coder",
        };
        self.ledger.append_signed(
            "brain_selection",
            json!({
                "intent_id": intent.intent_id,
                "brain": brain_str
            }),
            &self.authority,
            self.state
        )?;

        // ---- Stage 15: Controlled Brain Invocation ----
        let response_text = call_brain(brain_str, &intent.request)
            .map_err(|_| "Brain invocation failed")?;

        let request_hash = blake3::hash(intent.request.as_bytes()).to_hex().to_string();
        let response_hash = blake3::hash(response_text.as_bytes()).to_hex().to_string();

        self.ledger.append_signed(
            "brain_response",
            json!({
                "intent_id": intent.intent_id,
                "brain": brain_str,
                "request_hash": request_hash,
                "response_hash": response_hash
            }),
            &self.authority,
            self.state
        )?;

        let fin = Finalize::new(intent);

        self.ledger.append_signed(
            "finalize",
            json!({
                "intent_id": fin.intent_id,
                "intent_hash": fin.intent_hash
            }),
            &self.authority,
            self.state
        )?;

        self.refresh_state();
        Ok(fin)
    }
    fn refresh_state(&mut self) {
        if !self.ledger.verify_chain(&self.authority) {
            self.state = CoreState::Red;
        }
    }

    // -------- Stage 9: Query Surface --------

    pub fn snapshot(&self) -> CoreSnapshot {
        CoreSnapshot {
            state: self.state,
            chain_valid: self.chain_valid(),
            ledger_len: self.ledger_len(),
        }
    }

    pub fn proof_bundle(&self, intent_id: Option<&str>) -> ProofBundle {
        let snapshot = self.snapshot();
        let boot_receipts = self.ledger.filter_kind("boot_receipt");
        let execution_receipts = self.ledger.filter_kind("execution_receipt");

        let intent_slice = intent_id.map(|id| {
            IntentProofSlice::new(id.to_string(), self.ledger.filter_intent(id))
        });

        ProofBundle {
            generated_at_unix: ProofBundle::now_unix(),
            snapshot,
            boot_receipts,
            execution_receipts,
            intent_slice,
        }
    }

    pub fn export_proof_bundle_json(&self, path: &str, intent_id: Option<&str>) -> Result<(), &'static str> {
        let bundle = self.proof_bundle(intent_id);
        bundle.write_json_file(path)
    }
}
