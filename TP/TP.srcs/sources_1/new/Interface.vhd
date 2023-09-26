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
begin


end Interface_arch;
