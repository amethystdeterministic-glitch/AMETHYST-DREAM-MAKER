use serde_json::json;

use crate::authority::AuthorityRoot;
use crate::ledger::Ledger;
use crate::lifecycle::{Intent, TreeGate, Finalize};
use crate::state::CoreState;

pub struct OdinCore {
    authority: AuthorityRoot,
    ledger: Ledger,
    state: CoreState,
}

impl OdinCore {
    pub fn boot_ephemeral() -> Self {
        let authority = AuthorityRoot::new_ephemeral();
        let mut ledger = Ledger::new();
        let mut state = CoreState::Green;

        ledger.append_signed("genesis", json!({"event": "genesis"}), &authority, state)
            .expect("Genesis append failed");

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

    /// Advisory-only: record brain outputs as evidence.
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

    /// Stage 6: record a tool execution receipt (authoritative evidence).
    /// Requires finalized intent and single-shot execution.
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
}
