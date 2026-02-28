use odin_core::OdinCore;

fn main() {
    println!("ODIN Core Booting...");

    let mut core = OdinCore::boot_ephemeral();

    println!("Boot chain valid: {}", core.chain_valid());
    println!("Core state: {:?}", core.state());

    println!("Ledger entries: {}", core.ledger_len());
    println!("Chain valid: {}", core.chain_valid());
    println!("Core state: {:?}", core.state());
}
