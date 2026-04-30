module HazardDetectionUnit (
    input [4:0] idex_rs1,
    input [4:0] idex_rs2,
    input [4:0] exmem_rd,

    input [6:0] idex_op,
    input [6:0] exmem_op,

    output reg stall
);

    localparam LW    = 7'b000_0011;
    localparam SW    = 7'b010_0011;
    localparam BEQ   = 7'b110_0011;
    localparam ALUop = 7'b001_0011;

    initial begin
        stall = 1'b0;
    end

    always @(*) begin
        // Padrão: pipeline segue sem pausa.
        stall = 1'b0;

        // Único caso de stall: load-use.
        // Se a instrução à frente é LW e a instrução atual em EX quer ler o
        // mesmo registrador de destino, o dado ainda não está pronto a tempo.
        // Então inserimos 1 bolha (stall = 1).

        if ((exmem_op == LW) && (exmem_rd != 5'd0) &&
            ((exmem_rd == idex_rs1) || (exmem_rd == idex_rs2))) begin
            stall = 1'b1;
        end

    end

endmodule
