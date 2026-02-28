use odin_core::OdinCore;
use odin_subsystem::{
    BrainRegistry, BrainSpec, make_brain_output,
    ToolCall
};
use odin_subsystem::api;
use serde_json::json;

fn main() {
    println!("ODIN Demo Booting (persistent)...");

    let mut core = OdinCore::boot();
    println!("Core state at boot: {:?}", core.state());

    let mut reg = BrainRegistry::new();
    reg.register(BrainSpec { name: "openclaw".into(), kind: "planner".into(), endpoint: "http://127.0.0.1:8090".into() });
    reg.register(BrainSpec { name: "qwen".into(), kind: "language".into(), endpoint: "http://127.0.0.1:8081".into() });
    reg.register(BrainSpec { name: "deepseek".into(), kind: "coder".into(), endpoint: "http://127.0.0.1:8082".into() });
    println!("Brains registered: {}", reg.list().len());

    let out = make_brain_output("openclaw", "User asked to create app demo", "Suggested plan: create_app:demo_from_subsystem");
    let _ = api::record_brain_evidence(&mut core, &out);

    let receipt = api::submit_intent_and_finalize(&mut core, "create_app:demo_from_subsystem");
    if !receipt.ok {
        println!("Receipt failed: {:?}", receipt.error);
        return;
    }
    let receipt_val = receipt.value.unwrap();

    let call = ToolCall {
        tool_name: "forge_create_app".to_string(),
        args: json!({"app":"demo_from_subsystem","template":"minimal"}),
    };

    let tool = api::execute_tool_for_intent(&mut core, &receipt_val.intent_id, &call);
    if tool.ok {
        println!("Tool result hash: {}", tool.value.unwrap().output_hash);
    } else {
        println!("Tool failed: {:?}", tool.error);
    }

    let proof_path = "odin_proof_bundle.json";
    let proof = api::export_proof_bundle_json(&core, proof_path, Some(&receipt_val.intent_id));
    println!("Proof export ok={} path={}", proof.ok, proof_path);

    println!("Ledger entries: {}", core.ledger_len());
    println!("Chain valid: {}", core.chain_valid());
    println!("Core state: {:?}", core.state());
}
