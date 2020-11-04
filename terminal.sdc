create_clock -period 50MHz -name {clk50} [get_ports {clk50}]
create_generated_clock -name {vt52:terminal|vga:video|vgaclk} -divide_by 2 -source [get_ports {clk50}] [get_registers {vt52:terminal|vga:video|vgaclk}]
