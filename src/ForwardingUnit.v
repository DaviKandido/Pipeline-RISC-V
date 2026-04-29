module ForwardingUnit (
    input  [4:0] idex_rs1,
    input  [4:0] idex_rs2,
    input  [4:0] exmem_rd,
    input  [4:0] memwb_rd,

    input  [6:0] exmem_op,
    input  [6:0] memwb_op,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    localparam NO_FORWARD  = 2'b00;
    localparam FROM_MEM    = 2'b01;
    localparam FROM_WB_ALU = 2'b10;
    localparam FROM_WB_LD  = 2'b11;

    localparam LW    = 7'b000_0011;
    localparam ALUop = 7'b001_0011;

    initial begin
      forwardA = NO_FORWARD;
      forwardB = NO_FORWARD;
    end

always @(*) begin
    // Padrão: sem bypass. Só mudamos se detectarmos dependência válida.
    forwardA = NO_FORWARD;
    forwardB = NO_FORWARD;


    //* *************** Logica do ForwardingUnit ***************
    // Explicação da lógica deste código:
    // 1. Verificação dos Operandos: Primeiro, verificamos se o destino (rd) 
    //    em EX/MEM ou MEM/WB é igual ao operando A (rs1) ou B (rs2) na instrução ID/EX.
    // 2. Prioridades: Se o destino for encontrado:
    //    - Prioridade 1: resultado mais recente em EX/MEM
    //    - Prioridade 2: resultado em MEM/WB
    // 3. Tipo de Forwarding: Dependendo do tipo de operação (LW ou ALU), 
    //    selecionamos o tipo de forwarding apropriado.
    
    // Regra geral:
    // 1) EX/MEM tem prioridade (valor mais novo).
    // 2) MEM/WB é segunda opção.
    // 3) Nunca encaminhar x0 (rd == 0).
    // 4) Se EX/MEM for LW, NÃO usar FROM_MEM: nesse estágio o load ainda
    //    não trouxe o dado da memória, só o endereço calculado.
    // ---------- Operando A (rs1) ----------
    if ((exmem_rd != 5'd0) && (exmem_rd == idex_rs1) && (exmem_op != LW)) begin
        // rs1 depende da instrução logo à frente -> bypass direto de EX/MEM.
        forwardA = FROM_MEM;
    end
    else if ((memwb_rd != 5'd0) && (memwb_rd == idex_rs1)) begin
        // rs1 depende de instrução em WB -> escolher tipo de origem em WB.
        if (memwb_op == LW)
            forwardA = FROM_WB_LD;
        else
            forwardA = FROM_WB_ALU;
    end
    // ---------- Operando B (rs2) ----------
    if ((exmem_rd != 5'd0) && (exmem_rd == idex_rs2) && (exmem_op != LW)) begin
        // rs2 depende da instrução logo à frente -> bypass direto de EX/MEM.
        forwardB = FROM_MEM;
    end
    else if ((memwb_rd != 5'd0) && (memwb_rd == idex_rs2)) begin
        // rs2 depende de instrução em WB -> escolher tipo de origem em WB.
        if (memwb_op == LW)
            forwardB = FROM_WB_LD;
        else
            forwardB = FROM_WB_ALU;
    end
end

endmodule
