----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2023 11:32:47
-- Design Name: 
-- Module Name: interface - interface_arch
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

entity interface is
    generic (
      -- Constant parameters
      addr_bits : integer := 19;
      data_bits : integer := 36
      );
    Port ( 
    User_Data_In : in STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    User_Data_Out : out STD_LOGIC_VECTOR(data_bits - 1 downto 0);
    User_Address : in  STD_LOGIC_VECTOR(addr_bits - 1 downto 0);
    READ : in STD_LOGIC;
    WRITE : in STD_LOGIC;
    CLKO_SRAM : in STD_LOGIC
    );
end interface;

architecture interface_arch of interface is

    --Inputs
    signal nBWA : STD_LOGIC := '0';
    signal nBWB : STD_LOGIC := '0';
    signal nBWC : STD_LOGIC := '0';
    signal nBWD : STD_LOGIC := '0';
    signal ZZ : STD_LOGIC := '0';
    signal Lbo_n : STD_LOGIC := '0';
    signal nCKE : STD_LOGIC := '0';
    signal nRW : STD_LOGIC;
	SIGNAL nADVLD :  std_logic := '0';
	SIGNAL nOE:  std_logic := '0';
	SIGNAL nCE:  std_logic := '0';
	SIGNAL nCE2:  std_logic := '0';
	SIGNAL CE2:  std_logic := '1';
	SIGNAL SA :  std_logic_vector(addr_bits - 1 downto 0);
	
	signal T_IO_D : STD_LOGIC;
	signal T_IO : STD_LOGIC;
    signal S_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
    signal E_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
    signal ES_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
    
    signal data_out_D : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
    
    
    -- Declaration du Entrée sortie
    COMPONENT test_io
	PORT(
		TRIG : IN std_logic;
		ENTREE : IN std_logic;    
		E_S : INOUT std_logic;      
		SORTIE : OUT std_logic
		);
	END COMPONENT;
	
	-- Declaration de la bascule D
	COMPONENT Bascule_D is
    generic (
        WIDTH : integer := 1
    );
    Port (
        CLK : in STD_LOGIC;
        D : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        Q : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
    end COMPONENT;
    
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
    
    
    constant S_IDLE : std_logic_vector (2 downto 0) := "111"; 
	constant S_READ : std_logic_vector (2 downto 0) := "011"; 
  	constant S_WRITE : std_logic_vector (2 downto 0) := "000";
  	signal ETATG : std_logic_vector (2 downto 0);
    
begin
    -- Initialisation
    T_IO_D <= ETATG(0);
    nRW <= ETATG(1);

    process(CLKO_SRAM)
    begin
        case ETATG is
            when S_IDLE =>
                if READ = '1' then
                        SA <= User_Address;
                        ETATG <= S_READ;
                elsif WRITE = '1' then
                        SA <= User_Address;
                        ETATG <= S_WRITE;
                else
                    --User_Data_Out <= data_out_D;  -- (1)
                    ETATG <= S_IDLE;
                end if;

            when S_READ =>
                if falling_edge(CLKO_SRAM) then
                    data_out_D <= S_IO;
                end if;
                if READ = '1' then
                    ETATG <= S_READ;
                elsif WRITE = '1' then
                    ETATG <= S_WRITE;
                else
                    ETATG <= S_IDLE;
                end if;
                
                
            when S_WRITE =>
                if rising_edge(CLKO_SRAM) then
                    E_IO <= User_Data_In;
                end if;
                if WRITE = '1' then
                    ETATG <= S_WRITE;
                elsif READ = '1' then
                    ETATG <= S_READ;
                else
                    ETATG <= S_IDLE;
                end if;

            when others =>
                ETATG <= S_IDLE;
        end case;
end process;

User_Data_Out <= data_out_D;

process(CLKO_SRAM)
begin
    T_IO <= T_IO_D;
end process;

    SRAM1 : mt55l512y36f port map
        (ES_IO, User_Address, '0', CLKO_SRAM, nCKE, nADVLD, '0', '0', '0', '0', nRW, nOE, nCE, nCE2, CE2, '0');
    
    IO_G : for I in 0 to (data_bits - 1) generate
        io_D : test_io port map (T_IO, E_IO(I), ES_IO(I), S_IO(I));
    end generate;



end interface_arch;
