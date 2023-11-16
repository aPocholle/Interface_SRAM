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
      trigger_bits : integer := 1;

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
    User_Address : in  STD_LOGIC_VECTOR(addr_bits - 1 downto 0);
    READ : in STD_LOGIC;
    WRITE : in STD_LOGIC;
    CLKO_SRAM : in STD_LOGIC
    );
end Interface;

architecture Interface_arch of Interface is

    --constants
  	constant TCLKH    : time := 15 ns;
  	constant TCLKL    : time := 15 ns;

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
	SIGNAL READ_D:  std_logic;
	SIGNAL READ_D2:  std_logic;
	SIGNAL READ_D3:  std_logic;
    
    
    
    -- Declaration des iob pour chaque Entre/sortie
    signal T_IO : STD_LOGIC;
    signal T_IO_D : STD_LOGIC;
    signal S_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
    signal E_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
    signal ES_IO : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
    
    
    signal data_in_D : STD_LOGIC_VECTOR(data_bits - 1 downto 0) := (others => '0');
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
  	
    
-- Debut de l'architecture
begin

    -- Initialisation
    T_IO_D <= ETATG(0);
    nRW <= ETATG(1);
    
    IO_G : for I in 0 to (data_bits - 1) generate
        io_D : test_io port map (T_IO, E_IO(I), ES_IO(I), S_IO(I));
    end generate;
    
    -- Processus principal
    process(CLKO_SRAM)
    begin
    if rising_edge(CLKO_SRAM) then
        case ETATG is
            when S_IDLE =>
                if READ_D = '1' then
                    ETATG <= S_READ;
                    SA <= User_Address;  -- Mémorisez immédiatement l'adresse pour la lecture
                elsif WRITE = '1' then
                    ETATG <= S_WRITE;
                    SA <= User_Address;  -- Mémorisez immédiatement l'adresse pour l'écriture
                else
                    User_Data_Out <= data_out_D;  -- (1)
                    ETATG <= S_IDLE;
                end if;

            when S_READ =>
                -- Écrivez l'adresse dans la SRAM
                SA <= User_Address;
                
                User_Data_Out <= data_out_D;
            
                if READ_D = '1' then
                    ETATG <= S_READ;
                elsif WRITE = '1' then
                    ETATG <= S_WRITE;
                else
                    -- Désactivez la sélection de la SRAM
                    ETATG <= S_IDLE;
                end if;
                
                
            when S_WRITE =>
                -- Écrivez l'adresse dans la SRAM
                SA <= User_Address;
                
                -- Bascule D pour décaler les données
                E_IO <= data_in_D;

                if WRITE = '1' then
                    ETATG <= S_WRITE;
                elsif READ = '1' then
                    ETATG <= S_READ;
                else
                    -- Désactivez la sélection de la SRAM
                    ETATG <= S_IDLE;
                end if;

            when others =>
                ETATG <= S_IDLE;
        end case;
    end if;
end process;

process(CLKO_SRAM)
    begin
        if rising_edge(CLKO_SRAM) then
            T_IO <= T_IO_D;
            READ_D2 <= READ;
            READ_D3 <= READ_D2;
            READ_D <= READ;
        end if;
end process;


    DFF_instance_donnees : Bascule_D generic map (WIDTH => data_bits)
    port map (
        CLK => CLKO_SRAM,
        D => User_Data_In,
        Q => data_in_D
    );
    
    DFF2_instance_donnees : Bascule_D generic map (WIDTH => data_bits)
    port map (
        CLK => CLKO_SRAM,
        D => S_IO,
        Q => data_out_D
    );
    
    
    


    SRAM1 : mt55l512y36f port map
        (ES_IO, SA, '0', CLKO_SRAM, nCKE, nADVLD, '0',
         '0', '0', '0', nRW, nOE, nCE, nCE2, CE2, '0');

end Interface_arch;
