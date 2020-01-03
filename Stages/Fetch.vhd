library ieee;
use ieee.std_logic_1164.all;
package FetchPackage is
	component Fetch is
		port ( 
			fetch_en, clk: in std_logic;
			PC: in std_logic_vector(15 downto 0);
			instruction, PC_new, PC_old: out std_logic_vector(15 downto 0)
		);
	end component Fetch;
end package FetchPackage;


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ROMPackage.all;
use work.Blocks.all;
use work.Register16Package.all;

entity Fetch is
   port ( 
		fetch_en, clk: in std_logic;
		PC: in std_logic_vector(15 downto 0);
		instruction, PC_new, PC_old: out std_logic_vector(15 downto 0)
	);
end entity Fetch;

architecture Struct of Fetch is
	signal next_instr_addr, instr: std_logic_vector(15 downto 0);
	
	begin
	
	rom1: ROM port map (rom_addr=>PC, rom_dataout=>instr);
	plus2: Plus1Adder port map (A=>PC, PC_inc_en=>'1', S=>next_instr_addr);

	IF_ID1: Register16 port map(d=>instr, clk=>clk, en=>fetch_en, o=>instruction);
	IF_ID3: Register16 port map(d=>PC, clk=>clk, en=>fetch_en, o=>PC_old);
	
	pc_new_process : process(clk, fetch_en)
	begin
		if(falling_edge(clk) and fetch_en='1') then
			PC_new <= next_instr_addr;
		end if;
	end process;
	
	
		
end Struct;
