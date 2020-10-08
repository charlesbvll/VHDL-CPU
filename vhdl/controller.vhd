library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
  type state_type IS (FETCH1, FETCH2, DECODE, BRANCH, CALL, CALLR, JMP, JMPI, I_OP, R_OP, LOAD1, LOAD2, STORE, BREAK, I_EXEC, R_EXEC);
  signal s_current, s_next : state_type;
  signal s_op : std_logic_vector(7 downto 0);
  signal s_opx : std_logic_vector(7 downto 0);

  begin

  s_op <= "00" & op;
  s_opx <= "00" & opx;

  final_state_machine : process(clk, reset_n) is
    begin
      if(reset_n = '0') then
        s_current <= FETCH1;
      elsif(rising_edge(clk)) then
        s_current <= s_next;
      end if;
  end process final_state_machine;

op_alu_process : process(s_op, s_opx) is
  begin
    case s_op is
      when X"04" => op_alu <= "000" & op(5 downto 3);
      when X"0C" => op_alu <= "100" & op(5 downto 3);
      when X"14" => op_alu <= "100" & op(5 downto 3);
      when X"1C" => op_alu <= "100" & op(5 downto 3);
      when X"28" => op_alu <= "011" & op(5 downto 3);
      when X"30" => op_alu <= "011" & op(5 downto 3);
      when X"06" => op_alu <= "011100";
      when X"08" => op_alu <= "011" & op(5 downto 3);
      when X"10" => op_alu <= "011" & op(5 downto 3);
      when X"18" => op_alu <= "011" & op(5 downto 3);
      when X"20" => op_alu <= "011" & op(5 downto 3);
      when X"0E" => op_alu <= "011" & op(5 downto 3);
      when X"16" => op_alu <= "011" & op(5 downto 3);
      when X"1E" => op_alu <= "011" & op(5 downto 3);
      when X"26" => op_alu <= "011" & op(5 downto 3);
      when X"2E" => op_alu <= "011" & op(5 downto 3);
      when X"36" => op_alu <= "011" & op(5 downto 3);
      when X"3A" =>
        case s_opx is
          when X"12" => op_alu <= "110" & opx(5 downto 3);
          when X"1A" => op_alu <= "110" & opx(5 downto 3);
          when X"3A" => op_alu <= "110" & opx(5 downto 3);
          when X"02" => op_alu <= "110" & opx(5 downto 3);
          when X"31" => op_alu <= "000" & opx(5 downto 3);
          when X"39" => op_alu <= "001" & opx(5 downto 3);
          when X"08" => op_alu <= "011" & opx(5 downto 3);
          when X"10" => op_alu <= "011" & opx(5 downto 3);
          when X"06" => op_alu <= "100" & opx(5 downto 3);
          when X"0E" => op_alu <= "100" & opx(5 downto 3);
          when X"16" => op_alu <= "100" & opx(5 downto 3);
          when X"1E" => op_alu <= "100" & opx(5 downto 3);
          when X"13" => op_alu <= "110" & opx(5 downto 3);
          when X"1B" => op_alu <= "110" & opx(5 downto 3);
          when X"3B" => op_alu <= "110" & opx(5 downto 3);
          when X"18" => op_alu <= "011" & opx(5 downto 3);
          when X"20" => op_alu <= "011" & opx(5 downto 3);
          when X"28" => op_alu <= "011" & opx(5 downto 3);
          when X"30" => op_alu <= "011" & opx(5 downto 3);
          when X"03" => op_alu <= "110" & opx(5 downto 3);
          when X"0B" => op_alu <= "110" & opx(5 downto 3);
          when others => op_alu <= "000000";
        end case ;
      when others => op_alu <= "000000";
    end case;
  end process op_alu_process;

change_s_next : process(s_current, s_op, s_opx) is
begin

    branch_op <= '0';
    imm_signed <= '0';
    ir_en <= '0';
    pc_add_imm <= '0';
    pc_en <= '0';
    pc_sel_a <= '0';
    pc_sel_imm <= '0';
    rf_wren <= '0';
    sel_addr <= '0';
    sel_b <= '0';
    sel_mem <= '0';
    sel_pc <= '0';
    sel_ra <= '0';
    sel_rC <= '0';
    read <= '0';
    write <= '0';

    case s_current is
      when FETCH1 =>
        read <= '1';
        s_next <= FETCH2;
      when FETCH2 =>
        pc_en <= '1';
        ir_en <= '1';
        s_next <= DECODE;
      when DECODE =>
        case s_op is
          when X"15" =>
            s_next <= STORE;
          when X"17" =>
            s_next <= LOAD1;
          when X"04" =>
            s_next <= I_OP;
          when X"0C" => s_next <= I_EXEC;
          when X"14" => s_next <= I_EXEC;
          when X"1C" => s_next <= I_EXEC;
          when X"28" => s_next <= I_EXEC;
          when X"30" => s_next <= I_EXEC;
          when X"08" => s_next <= I_OP;
          when X"10" => s_next <= I_OP;
          when X"18" => s_next <= I_OP;
          when X"20" => s_next <= I_OP;
          when X"00" =>
            s_next <= CALL;
          when X"01" =>
            s_next <= JMPI;
          when X"06" | X"0E" | X"16" | X"1E" | X"26" | X"2E" | X"36" =>
            s_next <= BRANCH;
          when X"3A" =>
            case s_opx is
              when X"1D" =>
                s_next <= CALLR;
              when X"05" | X"0D" =>
                s_next <= JMP;
              when X"34" =>
                s_next <= BREAK;
              when X"12" => s_next <= R_EXEC;
              when X"1A" => s_next <= R_EXEC;
              when X"3A" => s_next <= R_EXEC;
              when X"02" => s_next <= R_EXEC;
              when others => s_next <= R_OP;
            end case ;
          when others => s_next <= FETCH1;
        end case;


      when I_EXEC =>
        rf_wren <= '1';
        s_next <= FETCH1;
      when R_EXEC =>
        rf_wren <= '1';
        sel_rC <= '1';
        s_next <=FETCH1;
      when BRANCH =>
        branch_op <= '1';
        sel_b <= '1';
        pc_add_imm <= '1';
        s_next <=FETCH1;
      when CALL =>
        rf_wren <= '1';
        sel_pc <= '1';
        sel_ra <= '1';
        pc_en <= '1';
        pc_sel_imm <= '1';
        s_next <=FETCH1;
      when CALLR =>
        rf_wren <= '1';
        sel_pc <= '1';
        sel_ra <= '1';
        pc_en <= '1';
        pc_sel_a <= '1';
        s_next <=FETCH1;
      when JMP =>
        pc_en <= '1';
        pc_sel_a <= '1';
        s_next <=FETCH1;
      when JMPI =>
        pc_en <= '1';
        pc_sel_imm <= '1';
        s_next <=FETCH1;
      when I_OP =>
        rf_wren <= '1';
        imm_signed <= '1';
        s_next <= FETCH1;
      when R_OP =>
        rf_wren <= '1';
        sel_b <= '1';
        sel_rC <= '1';
        s_next <=FETCH1;
      when LOAD1 =>
        sel_addr <= '1';
        read <= '1';
        imm_signed <= '1';
        s_next <=LOAD2;
      when LOAD2 =>
        rf_wren <= '1';
        sel_mem <= '1';
        s_next <= FETCH1;
      when STORE =>
        sel_addr <= '1';
        write <= '1';
        imm_signed <= '1';
        s_next <= FETCH1;
      when BREAK =>
        sel_b <= '1';
        sel_rC <= '1';
        s_next <= BREAK;
    end case;
end process change_s_next;

end synth;
