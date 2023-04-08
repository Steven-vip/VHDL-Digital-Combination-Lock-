----------------------------------------------------------------------------------
-- Design Name: YIWEN SUN
-- Module Name: display - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
    Port ( number : in STD_LOGIC_VECTOR (3 downto 0);-- 4-digit binary input for selecting the number or letter to be displayed
           segs : out STD_LOGIC_VECTOR (7 downto 0));-- Selects output to 7-segment digital tube based on the number entered
end display;

architecture Behavioral of display is

begin
 segs(7) <= '1';
 with number SELect
  segs(6 downto 0)<= "1111001" when "0001",   --1
        "0100100" when "0010",   --2
        "0110000" when "0011",   --3
        "0011001" when "0100",   --4
        "0010010" when "0101",   --5
        "0000010" when "0110",   --6
        "1111000" when "0111",   --7
        "0000000" when "1000",   --8
        "0010000" when "1001",   --9
        "0001000" when "1010",   --A
        "0000011" when "1011",   --b
        "1000110" when "1100",   --C
        "0100001" when "1101",   --d
        "0000110" when "1110",   --E
        "1000111" when "1111",   --L(This has been changed to show L) 
        "1000000" when others;   --0

end Behavioral;

-- The above code block determines which segments of the 7-segment display will be turned on or off
-- based on the input 'number'. Each 7-bit binary value represents the segments that need to be turned
-- on to display the corresponding digit or letter. For example, "1111001" represents the segments needed
-- to display the number '1'.




