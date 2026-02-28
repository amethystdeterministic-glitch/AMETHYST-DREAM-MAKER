use odin_core::OdinCore;
use odin_subsystem::{
    BrainRegistry, BrainSpec, make_brain_output,
    syscall_record_brain_output, syscall_submit_and_finalize,
    ToolCall, syscall_execute_tool_for_intent
};
use serde_json::json;

fn main() {
    println!("ODIN Demo Booting...");

    let mut core = OdinCore::boot_ephemeral();
    println!("Core state at boot: {:?}", core.state());

    // Register brains (metadata only)
    let mut reg = BrainRegistry::new();
    reg.register(BrainSpec {
        name: "openclaw".to_string(),
        kind: "planner".to_string(),
        endpoint: "http://127.0.0.1:8090".to_string(),
    });
    reg.register(BrainSpec {
        name: "qwen".to_string(),
        kind: "language".to_string(),
        endpoint: "http://127.0.0.1:8081".to_string(),
    });
    reg.register(BrainSpec {
        name: "deepseek".to_string(),
        kind: "coder".to_string(),
        endpoint: "http://127.0.0.1:8082".to_string(),
    });

    println!("Brains registered: {}", reg.list().len());

    // Advisory brain output recorded as evidence
    let input = "User asked to create app demo";
    let out = make_brain_output("openclaw", input, "Suggested plan: create_app:demo_from_subsystem");
    syscall_record_brain_output(&mut core, &out).expect("record brain event");

    // Lifecycle: submit + finalize
    let receipt = syscall_submit_and_finalize(&mut core, "create_app:demo_from_subsystem")
        .expect("subsystem lifecycle failed");

    // Tool mediation: execute simulated tool for finalized intent
    let call = ToolCall {
        tool_name: "forge_create_app".to_string(),
        args: json!({"app":"demo_from_subsystem","template":"minimal"}),
    };

    let result = syscall_execute_tool_for_intent(&mut core, &receipt.intent_id, &call)
        .expect("tool execution failed");

    println!("Receipt: intent_id={}, finalized={}", receipt.intent_id, receipt.finalized);
    println!("Tool result hash: {}", result.output_hash);

    println!("Ledger entries: {}", core.ledger_len());
    println!("Chain valid: {}", core.chain_valid());
    println!("Core state: {:?}", core.state());
}
