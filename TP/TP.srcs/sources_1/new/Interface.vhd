----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.09.2023 08:52:52
-- Design Name: 
-- Module Name: Interface - Interface_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Interface is
    generic (
      -- Constant parameters
      addr_bits : integer := 19;
      data_bits : integer := 36;

      -- Timing parameters for -10 (100 Mhz)
      tKHKH : time := 10.0 ns;
      tKHKL : time := 2.5 ns;
      tKLKH : time := 2.5 ns;
      tKHQV : time := 5.0 ns;
      tAVKH : time := 2.0 ns;
      tEVKH : time := 2.0 ns;
      tCVKH : time := 2.0 ns;
      tDVKH : time := 2.0 ns;
      tKHAX : time := 0.5 ns;
      tKHEX : time := 0.5 ns;
      tKHCX : time := 0.5 ns;
      tKHDX : time := 0.5 ns
      );
      
    Port ( 
    User_Data_In : in STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    User_Data_Out : out STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    User_Address : in  STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    READ : in STD_LOGIC;
    WRITE : in STD_LOGIC
    );
end Interface;

architecture Interface_arch of Interface is
    signal nBWA : STD_LOGIC := '0';
    signal nBWB : STD_LOGIC := '0';
    signal nBWC : STD_LOGIC := '0';
    signal nBWD : STD_LOGIC := '0';
    signal ZZ : STD_LOGIC := '0';
    signal Lbo_n : STD_LOGIC := '0';
    signal nCKE : STD_LOGIC := '0';
    signal Clk : STD_LOGIC := '0';
    signal nRW : STD_LOGIC;
    
    
    -- Declaration des iob pour chaque Entre/sortie
    signal T_IO : STD_LOGIC;
    signal S_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    signal E_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    signal ES_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    
    COMPONENT test_io
	PORT(
		TRIG : IN std_logic;
		ENTREE : IN std_logic;    
		E_S : INOUT std_logic;      
		SORTIE : OUT std_logic
		);
	END COMPONENT;
    
    -- Declaration de la SRAM
    COMPONENT mt55l512y36f
    PORT(
        Dq        : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0);   -- Data I/O
        Addr      : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);   -- Address
        Lbo_n     : IN    STD_LOGIC;                                   -- Burst Mode
        Clk       : IN    STD_LOGIC;                                   -- Clk
        Cke_n     : IN    STD_LOGIC;                                   -- Cke#
        Ld_n      : IN    STD_LOGIC;                                   -- Adv/Ld#
        Bwa_n     : IN    STD_LOGIC;                                   -- Bwa#
        Bwb_n     : IN    STD_LOGIC;                                   -- BWb#
        Bwc_n     : IN    STD_LOGIC;                                   -- Bwc#
        Bwd_n     : IN    STD_LOGIC;                                   -- BWd#
        Rw_n      : IN    STD_LOGIC;                                   -- RW#
        Oe_n      : IN    STD_LOGIC;                                   -- OE#
        Ce_n      : IN    STD_LOGIC;                                   -- CE#
        Ce2_n     : IN    STD_LOGIC;                                   -- CE2#
        Ce2       : IN    STD_LOGIC;                                   -- CE2
        Zz        : IN    STD_LOGIC                                    -- Snooze Mode
        );
    END COMPONENT;
    
    constant S_IDLE : std_logic_vector (3 downto 0) := "1100"; 
	constant S_READ : std_logic_vector (3 downto 0) := "1101"; 
  	constant S_WRITE : std_logic_vector (3 downto 0) := "0010";
  	signal ETATG : std_logic_vector (3 downto 0);
    
-- Debut de l'architecture
begin
    
    T_IO <= ETATG(0);
    nRW <= ETATG(1);
    
    
    IO_G : for I in 0 to (data_bits - 1) generate
        io_D : test_io port map (T_IO, E_IO(I), ES_IO(I), S_IO(I));
    end generate;
    
    process
    begin
        Clk <= not Clk;
        wait for 10ns;
    end process;
    
    process (Clk)
    begin
        case ETATG is
            when S_IDLE =>
                if READ = '1' then
                    ETATG <= S_READ;
                elsif WRITE = '1' then
                    ETATG <= S_WRITE;
                else
                    ETATG <= S_IDLE;
                end if;
    
            when S_READ =>
                if WRITE = '1' then
                    ETATG <= S_WRITE;
                else
                    
                    --Lecture
                    
                    ETATG <= S_IDLE;
                end if;
    
            when S_WRITE =>
                if READ = '1' then
                    ETATG <= S_READ;
                else
                    
                    --Ecriture
                    
                    ETATG <= S_IDLE;
                end if;
        end case;
    end process;
    
    






end Interface_arch;
