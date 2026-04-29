module BranchUnit (
    input  [31:0] pc_ex,
    input  [31:0] rs1_value,
    input  [31:0] rs2_value,
    input  [31:0] instruction,

    output reg        branch_taken,
    output reg [31:0] branch_target
);

    localparam BEQ = 7'b110_0011;

    wire [6:0] opcode;
    assign opcode = instruction[6:0];
    wire [31:0] branch_imm;


    assign branch_imm = {
        {20{instruction[31]}},
        instruction[7],
        instruction[30:25],
        instruction[11:8],
        1'b0
    };

    always @(*) begin
        // Valores padrão assumindo que o desvio NÃO vai acontecer.
        // O PC aponta para a próxima instrução (PC + 4).
        branch_taken  = 1'b0;
        branch_target = pc_ex + 32'd4;

        
        //* *************** Logica do BEQ ***************
        // Explicação da lógica deste código:
        // 1. Verificação do Opcode: Primeiro, garantimos que a instrução atual é 
        //    realmente um BEQ (Branch if Equal). Se não for, ignora e mantém os valores padrão.
        // 2. Comparação dos Operandos: Como a regra do BEQ exige que os valores 
        //    sejam iguais para o salto ocorrer, comparamos rs1_value e rs2_value no estágio EX (pc_ex).
        // 3. Tomada de Decisão: Se ambas as condições acima forem verdadeiras:
        //    - branch_taken = 1'b1: Avisamos o processador que o salto vai acontecer
        //      (isso vai acionar o sinal de 'flush' no RISCVCPU.v para limpar as instruções erradas).
        //    - branch_target: Calculamos o novo endereço somando a posição atual 
        //      (pc_ex) com o deslocamento calculado (branch_imm).
        if (opcode == BEQ) begin
            if (rs1_value == rs2_value) begin
                branch_taken = 1'b1;
                branch_target = pc_ex + branch_imm;
            end
        end

    end

endmodule
