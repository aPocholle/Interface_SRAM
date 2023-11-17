library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Interface_tb2 is
end Interface_tb2;

architecture Interface_tb2_arch of Interface_tb2 is

    -- D�claration de l'instance de l'interface � tester
    component Interface is
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
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    constant addr_bits : integer := 19;
    constant data_bits : integer := 36;

    -- D�claration des variables de test
    signal user_data_in : std_logic_vector(data_bits - 1 downto 0) := (others =>'0');
    signal user_data_out : std_logic_vector(data_bits - 1 downto 0) := (others =>'0');
    signal user_address : std_logic_vector(addr_bits - 1 downto 0) := (others =>'0');
    signal read : std_logic := '0';
    signal write : std_logic := '0';
    
    --constants
  	constant TCLKH    : time := 15 ns;
  	constant TCLKL    : time := 15 ns;
  	
  	constant nClk     : integer := 1;

begin

    -- Instanciation de l'interface � tester
    DUT : Interface port map (
        User_Data_In => user_data_in,
        User_Data_Out => user_data_out,
        User_Address => user_address,
        READ => read,
        WRITE => write,
        CLKO_SRAM => clk
    );

    -- G�n�ration du signal d'horloge
    process
  begin
    clk <= '0';
    wait for TCLKH;
    clk <= '1';
    wait for TCLKL;
  end process;

    -- R�initialisation de l'interface � tester
    process
    begin
        wait for 1*(TCLKL+TCLKH);
        wait until clk = '0'; -- On attend que la clock soit � 0.
        rst <= '0';
        wait;
    end process;

    


    process
    begin
        wait until rst = '0';
        
        -- INITIALISATION SRAM ET IO ---------------------   
                                      
        user_address <= "000"&x"0000";   
             
        -- Activer l'�criture                 
        write <= '1';                         
                                              
        -- �crire les donn�es dans l'interface
        user_data_in <= x"000000000";         
                                              
        -- Attendre que les donn�es soient �cr
        wait for nClk*(TCLKL+TCLKH);             
                                             
        -- D�sactiver l'�criture              
        write <= '0';   
        
        -- ECRITURE 1 ---------------------   
                                      
        user_address <= "000"&x"0001";   
             
        -- Activer l'�criture                 
        write <= '1';                         
                                              
        -- �crire les donn�es dans l'interface
        user_data_in <= x"111111111";         
                                              
        -- Attendre que les donn�es soient �cr
        wait for nClk*(TCLKL+TCLKH);             
                                             
        -- D�sactiver l'�criture              
        write <= '0';    
        
        
        -- ECRITURE 2 ---------------------
        
        user_address <= "000"&x"0002";
        
        -- Activer l'�criture
        write <= '1';

        -- �crire les donn�es dans l'interface
        user_data_in <= x"222222222";

        -- Attendre que les donn�es soient �crites
        wait for nClk*(TCLKL+TCLKH);

        -- D�sactiver l'�criture
        write <= '0';
        
        
        -- ECRITURE 3 ------------------------
        
        user_address <= "000"&x"0003";
        
        -- Activer l'�criture
        write <= '1';

        -- �crire les donn�es dans l'interface
        user_data_in <= x"333333333";
        
        -- Attendre que les donn�es soient �crites
        wait for nClk*(TCLKL+TCLKH);
        
        -- D�sactiver l'�criture
        write <= '0';
        
        
         -- ECRITURE 4 ------------------------
        
        user_address <= "000"&x"0004";

        -- Activer l'�criture
        write <= '1';
        
        -- �crire les donn�es dans l'interface
        user_data_in <= x"444444444";
        
        -- Attendre que les donn�es soient �crites
        wait for nClk*(TCLKL+TCLKH);

        -- D�sactiver l'�criture
        write <= '0';                     
                                                          
        
        -- LECTURE 1 ----------------------
        
        user_address <= "000"&x"0001";
        
         -- Activer la lecture
        read <= '1';

        -- Attendre que les donn�es soient disponibles
        wait for nClk*(TCLKL+TCLKH);

        -- D�sactiver la lecture
        read <= '0';
        
        
        -- LECTURE 2 ----------------------
        
        user_address <= "000"&x"0002";
        
         -- Activer la lecture
        read <= '1';
        
        -- Attendre que les donn�es soient disponibles
        wait for nClk*(TCLKL+TCLKH);

        -- D�sactiver la lecture
        read <= '0';

        
        -- LECTURE 3 ----------------------
        
        user_address <= "000"&x"0003";
         -- Activer la lecture
        read <= '1';

        -- Attendre que les donn�es soient disponibles
        wait for nClk*(TCLKL+TCLKH);

        -- D�sactiver la lecture
        read <= '0';
        
        
        -- LECTURE 4 ----------------------
        
        user_address <= "000"&x"0004";
        
         -- Activer la lecture
        read <= '1';

        -- Attendre que les donn�es soient disponibles
        wait for nClk*(TCLKL+TCLKH);

        -- D�sactiver la lecture
        read <= '0';
        
        
        -- On met des 0 pour delimit� la fin de la simulation
        user_data_in <= (others =>'0');
        
        wait;
    end process;
    

end Interface_tb2_arch;
