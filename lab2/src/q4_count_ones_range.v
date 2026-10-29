module user_module(
    input       [31:0]  a,
    input       [4:0]   b,
    input       [4:0]   c,
    output reg  [5:0]   out
);
integer i;
always @(*) begin 
    out = 0;
    for(i = 0; i < 32; i = i + 1) begin
        if(i >= b && i <= c)
            out = out + a[i];
    end
end
endmodule
