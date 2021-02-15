// Basic, 1-bbp, framebuffer-less vga output
// Designed for a simple, direct attach VGA adapter

module vga #(
    VGA_WIDTH = 0,
    VGA_HEIGHT = 0
) (
    input pxclk,
    input [2:0] rgb
);

endmodule
