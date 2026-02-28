use odin_core::OdinCore;
use odin_subsystem::syscall_submit_and_finalize;

fn main() {
    println!("ODIN Demo Booting...");

    let mut core = OdinCore::boot_ephemeral();

    println!("Core state at boot: {:?}", core.state());

    let receipt = syscall_submit_and_finalize(
        &mut core,
        "create_app:demo_from_subsystem",
    ).expect("subsystem syscall failed");

    println!(
        "Receipt: intent_id={}, finalized={}",
        receipt.intent_id,
        receipt.finalized
    );

    println!("Ledger entries: {}", core.ledger_len());
    println!("Chain valid: {}", core.chain_valid());
    println!("Core state: {:?}", core.state());
}
