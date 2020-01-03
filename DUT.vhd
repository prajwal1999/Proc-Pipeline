library ieee;
use ieee.std_logic_1164.all;
library work;

use work.ControllerPackage.all;
use work.FetchPackage.all;
use work.DecoderPackage.all;
use work.RegisterReadPackage.all;
use work.EXstagePackage.all;
use work.MemoryAccessPackage.all;
use work.Write_BackPackage.all;

entity DUT is
   port ( 
		clk, reset : in std_logic
	);
end entity DUT;

architecture Struct of DUT is
	-- fetch signals
	signal s_f_instr, s_f_PC_new, s_f_PC_old: std_logic_vector(15 downto 0);
	
	-- decode signals
	signal s_d_instr, s_d_Imm, s_d_PC_old_out : std_logic_vector(15 downto 0);
	-- register-read signals
	signal s_rr_data_out1, s_rr_data_out2, s_rr_instr, s_rr_bypass1, s_rr_bypass2: std_logic_vector(15 downto 0);
	signal s_R0, s_R1, s_R2, s_R3, s_R4, s_R5,s_R6, s_R7: std_logic_vector(15 downto 0);
	-- exe signals
	signal  s_exe_cout, s_exe_zout: std_logic;
	signal s_exe_instr, s_exe_data_out1, s_exe_data_out2: std_logic_vector(15 downto 0);
	-- memory-access signals
	signal s_ma_instr, s_ma_out1, s_ma_out2: std_logic_vector(15 downto 0);
	-- write-back signals
	signal s_wb_instr, s_wb_data_out, s_wb_PC_out: std_logic_vector(15 downto 0);
	signal s_wb_dest: std_logic_vector(2 downto 0);
	-- controller signals
	signal s_c_fetch_en, s_c_decode_en, s_c_rr_en, s_c_rr_wr_en, s_c_exe_en, s_c_ma_en, s_c_ma_wr_en, s_c_wb_en, s_c_zout, s_c_cout: std_logic;
	signal s_c_rr_sel_r1, s_c_rr_sel_r2: std_logic_vector(1 downto 0);

	begin
		
		fetch_inst: Fetch port map( fetch_en => s_c_fetch_en, clk => clk, PC => s_R7, instruction => s_f_instr, PC_new => s_f_PC_new, PC_old => s_f_PC_old );
		
			
		decode_inst: Decoder port map( decode_en => s_c_decode_en, clk => clk,
				instr_in => s_f_instr, PC_old_in => s_wb_PC_out,
				instr_out => s_d_instr, Imm => s_d_Imm, PC_old_out => s_d_PC_old_out
			);

			
		register_read_inst: RegisterRead port map(
				wr_en => s_c_rr_wr_en, clk => clk, RR_en => s_c_rr_en,
				instr_in => s_d_instr, Imm => s_d_Imm, PC_old_in => s_d_PC_old_out,
				from_exe_in => s_exe_data_out1, from_ma_in => s_ma_out1,
				sel_r1 => s_c_rr_sel_r1, sel_r2 => s_c_rr_sel_r2,
				wr_addr => s_wb_dest,
				wr_data => s_wb_data_out, PC_wr_data => s_f_PC_new,
				data_out1 => s_rr_data_out1, data_out2 => s_rr_data_out2, instr_out => s_rr_instr, bypass1 => s_rr_bypass1, 
				bypass2 => s_rr_bypass2, R0 => s_R0, R1 => s_R1, R2 => s_R2, R3 => s_R3, R4 => s_R4, R5 => s_R5, R6 => s_R6, R7 => s_R7
				);
			
			
		exe_inst: EXstage port map(
				clk => clk, exe_en => s_c_exe_en, cin => s_c_cout, zin => s_c_zout,
				data_in1 => s_rr_data_out1, data_in2 => s_rr_data_out2, instr_in => s_rr_instr, bypass1_in => s_rr_bypass1, bypass2_in => s_rr_bypass2,
				instr_out => s_exe_instr, data_out1 => s_exe_data_out1, data_out2 => s_exe_data_out2,
				cout => s_exe_cout, zout => s_exe_zout
				);
			
		memory_access_inst: MemoryAccess port map(
				MA_en => s_c_ma_en, wr_en => s_c_ma_wr_en, clk => clk,
				instr_in => s_exe_instr, data_in1 => s_exe_data_out1, data_in2 => s_exe_data_out2,
				instr_out => s_ma_instr, out1 => s_ma_out1, out2 => s_ma_out2
			);
			
		write_back_inst: Write_Back port map(
				wb_en => s_c_wb_en, clk => clk,
				instr_in => s_ma_instr, data_in1 => s_ma_out1, data_in2 => s_ma_out2, 
				data_out => s_wb_data_out, PC_out => s_wb_PC_out,
				dest => s_wb_dest, instr_out => s_wb_instr
			);
			
		controller_datapath: Controller port map(
		clk => clk, reset => reset,
		zin => s_exe_zout, cin => s_exe_cout,
		
		-- fetch controls
		fetch_instr => s_f_instr,
		fetch_en => s_c_fetch_en,
		
		-- decoder controls
		decode_instr => s_d_instr,-- decode se aane wali instr
		decode_en => s_c_decode_en,
		
	-- register read controls
		rr_instr => s_rr_instr, -- rr se aane wali instr
		rr_en => s_c_rr_en, rr_wr_en => s_c_rr_wr_en,
		rr_sel_r1 => s_c_rr_sel_r1, rr_sel_r2 => s_c_rr_sel_r2,
		
		-- execute controls
		exe_instr => s_exe_instr, -- exe se aane wali instr
		exe_en => s_c_exe_en, 

		-- memory access controls
		ma_instr => s_ma_instr, -- ma se aane wali instr
		ma_en => s_c_ma_en, ma_wr_en => s_c_ma_wr_en,

		--write back controls
		wb_instr => s_wb_instr, -- wb se aane wali instr
		wb_en => s_c_wb_en,

		-- zero carry
		zout => s_c_zout, cout => s_c_cout
		);
		
end Struct;
