use odin_core::OdinCore;

fn main() {
    println!("ODIN Core Booting (persistent)...");

    let core = OdinCore::boot();

    println!("Ledger entries: {}", core.ledger_len());
    println!("Chain valid: {}", core.chain_valid());
    println!("Core state: {:?}", core.state());
}
