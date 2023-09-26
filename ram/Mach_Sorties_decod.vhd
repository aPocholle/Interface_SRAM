-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Correction TD2
-- MACH3 a Sorties Decodees pour acceler le decodage des sorties
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity MACH3 is
  port (
    	CLK		: in  std_logic;
	RESET      	: in  std_logic;
    	A		: in  std_logic;
	B		: in  std_logic;
    	S1		: out  std_logic;
	S2		: out  std_logic
    );
end MACH3;


architecture arch_MACH3 of MACH3 is

  	constant ETAT1 : std_logic_vector (3 downto 0) := "0000";  --Encodage des etats avec S2 et S1 pour LSB
	constant ETAT2 : std_logic_vector (3 downto 0) := "0100";  --autres bits pour differencier les etats
  	constant ETAT3 : std_logic_vector (3 downto 0) := "0001";  --ayant les mêmes valeurs de S2 et S1
	constant ETAT4 : std_logic_vector (3 downto 0) := "0011";  --
	constant ETAT5 : std_logic_vector (3 downto 0) := "1000";  --

  	signal ETATG : std_logic_vector (3 downto 0);

  
begin

  S1 <= ETATG(0);
  S2 <= ETATG(1);

  connection : process (CLK, RESET)
  begin
    if (RESET = '1') then ETATG <= ETAT1;
                           
    elsif (CLK'event and CLK = '1') then
      
      case ETATG is
        when ETAT1 =>
           	if ((A = '1') and (B = '0')) 
		then ETATG <= ETAT2;
          	else ETATG  <= ETAT1;
          	end if;

         when ETAT2 =>
           	if ((A = '0') and (B = '1')) --Prioritaire donc sur la deuxieme condition
		then ETATG <= ETAT4;
          	else
			if ((A = '0') and (B = '0'))
			then ETATG  <= ETAT3;
			else ETATG <= ETAT2;
			end if;
          	end if;

	  when ETAT3 =>
           	if ((A = '1') and (B = '0')) --Prioritaire donc sur la deuxieme condition
		then ETATG <= ETAT2;
          	else
			if ((A = '1') and (B = '1'))
			then ETATG  <= ETAT1;
			else ETATG <= ETAT3;
			end if;
          	end if;

	  when ETAT4 =>
           	if ((A = '0') and (B = '0')) 
		then ETATG <= ETAT5;
          	else ETATG  <= ETAT4;
          	end if;

	  when ETAT5 =>
           	ETATG  <= ETAT1;      	
                   
        when others =>
          ETATG <= ETAT1;
          
      end case;
    end if;
  end process connection;


 end arch_MACH3;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- FIN
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
