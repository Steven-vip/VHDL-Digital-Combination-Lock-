----------------------------------------------------------------------------------
--Copyright: Yiwen SUN
--Date: 2023.04.08
--Version: Final
----------------------------------------------------------------------------------
-- Generic top level design file
----------------------------------------------------------------------------------
-- Import necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;
-- Define the top_level entity with input and output ports
entity top_level is
    Port ( CLK100MHZ: in std_logic;
	       BTNL, BTNR, BTNU, BTND, BTNC: in std_logic;        --Push buttons
	       SWITCHES:  in STD_LOGIC_VECTOR (3 downto 0);       --Slider switches
           LEDS:      out STD_LOGIC_VECTOR (7 downto 0):="10000000";      --LEDs
	       DIGITS:    out STD_LOGIC_VECTOR (7 downto 0):="11111111";      --Digits of 7-segment display
           SEGMENTS:  out STD_LOGIC_VECTOR (7 downto 0));  --Segments of 7-segment display             
end top_level;
-- Define the top_level architecture (Behavioral)
architecture Behavioral of top_level is
--Local declarations go here
signal previous: std_logic;
signal result: unsigned(7 downto 0);
constant myid: unsigned(15 downto 0):=x"5309";
signal input: STD_LOGIC_VECTOR(15 downto 0);
signal input1: STD_LOGIC_VECTOR(3 downto 0);
signal input2: STD_LOGIC_VECTOR(3 downto 0);
TYPE my_states IS (s0, s1, s2, s3, s4, s5, s6,s7,s8,s9,s10,lock,opens);
SIGNAL state: my_states;
signal wrong: unsigned(15 downto 0):=x"0000";
signal n:unsigned(15 downto 0):= x"0000";
signal clk_count : integer:= 0;
signal clk_1s_pulse : std_logic := '0';
signal rand_count:STD_LOGIC_VECTOR(1 downto 0):= "00";
signal rand1:STD_LOGIC_VECTOR(2 downto 0):="000";
signal rand2:STD_LOGIC_VECTOR(2 downto 0):="000";
signal number:STD_LOGIC_VECTOR(3 downto 0);
signal begin1:std_logic:='0';
-- Define the display component with input and output ports
component display
    port ( number: in std_logic_vector(3 downto 0);
           segs : out std_logic_vector(7 downto 0) );
end component;

begin
-- 1s clock generation process
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if begin1 ='1' then
            clk_count <= clk_count + 1;
            if clk_count = 100000000 then
--            if clk_count = 9 then
                clk_1s_pulse <= '1';
                clk_count <=0;
                else clk_1s_pulse<= '0';
            end if;
            end if;
        end if;
        end process;
     
-- Random number generation (0 to 4) process
            process(CLK100MHZ)
            begin
                if rising_edge(CLK100MHZ) then
                    rand_count <= rand_count + 1;
                end if;
            end process;   

-- "Rise" signal generation process
    process(CLK100MHZ)
        variable rise: std_logic; 
    begin
        if rising_edge(CLK100MHZ) then
            previous <= btnr;
            if btnr='1' and previous='0' then
                rise:='1';
            else
                rise:='0';
            end if;
        end if;
-- Main state machine process      
    IF (rising_edge(CLK100MHZ) ) THEN       
      CASE state IS
-- State s0: Initialize      
        WHEN s0 => IF btnc='1' THEN state <= s1;ELSIF btnu='1' --Full input mode
                            THEN state <= s6;rand1(1 downto 0)<=rand_count;--Secure input mode
                            ELSE state <= s0;leds<="10000000"; END IF;
-- State s1: Input first four bits
        WHEN s1 => IF rise='1' THEN state <= s2;input(15 downto 12)<=SWITCHES;
                            ELSE state <= s1;leds<="00000001"; END IF;
-- State s2: Input second four bits
        WHEN s2 => IF rise='1' THEN state <= s3;input(11 downto 8)<=SWITCHES; 
                            ELSE state <= s2;leds<="00000011"; END IF; 
-- State s3: Input third four bits
        WHEN s3 => IF rise='1' THEN state <= s4;input(7 downto 4)<=SWITCHES; 
                            ELSE state <= s3;leds<="00000111"; END IF; 
-- State s4: Input last four bits and move to s5
        WHEN s4 => IF rise='1' THEN input(3 downto 0)<=SWITCHES;state<=s5;                               
                            ELSE state <= s4;leds<="00001111"; END IF; 
-- State s5: Check if input is correct or not
        WHEN s5 => if input=x"5309" THEN  state <= opens;begin1<='1';--Correct zeroing
                            ELSE state <= lock;begin1<='1';wrong <= wrong + 2;end if;
 -- State s6: Display first random number and move to s7
        WHEN s6 =>  leds<="00010000";
                    IF rise='1' THEN input1(3 downto 0)<=SWITCHES;state<=s7;
                                    if rand_count=rand1(1 downto 0) then rand2(1 downto 0) <= rand1(1 downto 0)+1;
                                    else rand2(1 downto 0)<=rand_count;end if;--Give the second rand number a value                               
                            ELSE state <= s6;number(2 downto 0) <= rand1+1; DIGITS<="11111110"; END IF;   --Display the first random number        
-- State s7: Display second random number and move to s8
        WHEN s7 => leds<="00110000";
                   IF rise='1' THEN input2(3 downto 0)<=SWITCHES;state<=s8;DIGITS<="11111111" ;                              
                            ELSE state <= s7;number(2 downto 0) <= rand2+1; DIGITS<="11111110";END IF;        
-- State s8: Validate first input based on first random number
        WHEN s8 =>  CASE rand1(1 downto 0) IS
                      WHEN "00" => IF input1=x"5" then state<=s9;
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;
                      WHEN "01" => IF input1=x"3" then state<=s9;
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;                    
                      WHEN "10" => IF input1=x"0" then state<=s9;
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;
                      WHEN "11" => IF input1=x"9" then state<=s9;
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;     
                      WHEN OTHERS => state <= s0;
                      end case;                   
-- State s9: Validate second input based on second random number
        WHEN s9 => CASE rand2(1 downto 0) IS
                      WHEN "00" => IF input2=x"5" then state<=opens;begin1<='1';
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;
                      WHEN "01" => IF input2=x"3" then state<=opens;begin1<='1';
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;                    
                      WHEN "10" => IF input2=x"0" then state<=opens;begin1<='1';
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;
                      WHEN "11" => IF input2=x"9" then state<=opens;begin1<='1';
                                    else state<=lock;begin1<='1';wrong <= wrong + 2;end if;     
                      WHEN OTHERS => state <= s0;
                      end case;
-- State opens: Show the locker is open              
        WHEN lock =>    leds<="10101010";
                        DIGITS<="11111110";number <="1111";
                        if clk_1s_pulse = '1' then
                        n <= n + 1;
                        if n = wrong then
                           state <= lock;begin1<='0';leds<="10000000";number <="0000"; DIGITS<="11111111"; n <= (others => '0'); --SYW
                           else state<=lock;
                        end if;
                     end if;        
 -- State lock: Show the locker is locked
        WHEN opens =>leds<="11111111"; 
                     DIGITS<="11111110";number <="0000";
                     if clk_1s_pulse = '1' then
                       n <= n +1;
                     if n = 1 then
                        state <= s1;begin1<='0';leds<="10000000"; DIGITS<="11111111";n <= (others => '0'); --SYW
                      end if;
                      end if;
                      wrong <= x"0000";    
 -- Default state: s0
        WHEN OTHERS => state <= s0;
      END CASE;
    END IF;
  END PROCESS;

dd: display port map (number => number, segs => segments);

end Behavioral;	


