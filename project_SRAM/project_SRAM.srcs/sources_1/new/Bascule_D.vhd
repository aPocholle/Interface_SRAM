----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2023 15:18:04
-- Design Name: 
-- Module Name: Bascule_D - Behavioral
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

entity Bascule_D is
    generic (
        WIDTH : integer := 1
    );
    Port (
        CLK : in STD_LOGIC;
        D : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        Q : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end Bascule_D;

architecture Behavioral of Bascule_D is

    signal internalQ : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
begin
    process(CLK)
    begin
        if falling_edge(CLK) then
            internalQ <= D;
        end if;
    end process;

    Q <= internalQ;


end Behavioral;
