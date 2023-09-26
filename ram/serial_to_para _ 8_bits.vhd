----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.10.2020 13:13:41
-- Design Name: 
-- Module Name: serial_to_para _ 8_bits - Behavioral
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

entity serial_to_para_height_bits is
    Port ( DATA : in STD_LOGIC;
           CLK : in STD_LOGIC;
           PARA_OUT : out std_logic_vector(7 downto 0)
           );
end serial_to_para_height_bits;

architecture Behavioral of serial_to_para_height_bits is

component FF_jd
generic(Bus_Size: integer := 8); 
    Port ( D : in STD_LOGIC_VECTOR(Bus_Size-1 downto 0);
           Q : out STD_LOGIC_VECTOR (Bus_Size-1 downto 0);
           CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           EN : in STD_LOGIC);
end component;

component Heightb_counter
    Port ( ENABLE : in STD_LOGIC;
           UP_DOWN : in STD_LOGIC;
           LOAD : in STD_LOGIC;
           BUS_LOAD : in STD_LOGIC_VECTOR (7 downto 0);
           RESET : in STD_LOGIC;
           COUNT : out STD_LOGIC_VECTOR (7 downto  0);
           CLK : in std_logic
           );
end component;

--signaux internes
signal b: STD_LOGIC_VECTOR (7 downto 0);
signal sdata: STD_LOGIC_VECTOR (0 downto 0);
signal reset: std_logic;


--signaux compteur
signal enable_compteur: std_logic;
signal up_down:std_logic;
signal load: std_logic;
signal bus_load: std_logic_vector (7 downto 0);
signal count: std_logic_vector (7 downto 0);


--signaux Flip-Flops
signal enable_ff: std_logic;


begin

    --initialisation des signaux internes
    reset<='0';
    sdata(0)  <=DATA;
    
    --initialisation compteur
    enable_compteur<='1';
    up_down <='1';
    load<='1';
    bus_load<=(others => '0');
    
    --initialisation Flip-Flops
    enable_ff<='1';
    
    
    FF_REG: 
    for I in 0 to 7 generate
        BASC_0: if I = 0 generate
            U0:FF_jd generic map (Bus_Size => 1) port map(
                sdata,
                b(0 downto 0),
                CLK,
                RESET,
                enable_ff);
        end generate BASC_0;
        
        BASC_X:if I > 0 generate
            UX:FF_jd generic map (Bus_Size => 1) port map(
            b(I-1 downto I-1),
            b(I downto I),
            CLK,
            RESET,
            enable_ff);
        end generate BASC_X;
    end generate FF_REG;
    
    compteur:Heightb_counter port map(enable_compteur,up_down,load,bus_load,reset,count,CLK);
    
    p1: process (CLK)
    begin
        if(count(3)='1') then
            
            reset<='1';
        end if;
    end process;
        
     PARA_OUT <= b;   
    
end Behavioral;
