#[derive(Debug, Clone, Copy)]
pub struct KernelInputs {
    pub crisis_flag: bool,
    pub divergence: f32,
}

#[derive(Debug, Clone, Copy)]
pub struct KernelOutput {
    pub route: u32,
    pub d_norm: f32,
}

/// ODIN Kernel primitive.
/// Pure function.
/// No IO.
/// No state.
/// No randomness.
pub fn odin_kernel_route(input: KernelInputs) -> KernelOutput {
    let route = if input.crisis_flag { 1 } else { 0 };
    let d_norm = input.divergence.abs();
    KernelOutput { route, d_norm }
}
