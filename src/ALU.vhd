-------------------------------------------------------------------
-- Name        : ALU.vhd
-- Author      : Nycolas
-- Data	       : 01/07/22
-- Description : Unidade logica aritmetica
----------------------------------------------------------------------------------------------------
--	ALUOP  -- 	OPERACAO 	-- 	RESULT_LSB 	       -- 	RESULT_MSB
--  x"03"  --   $<$         --  (A $<$ B ? 1 : 0)  --   0
--  X"04"  --   $==$        --  (A $==$ B ? 1 : 0) --   0
-- 	x"10"  -- 	+		    -- 	A + B		       -- 	0
-- 	x"20"  -- 	*		    -- 	A * B (7 -- 0)	   -- 	A * B (15 -- 8)
-- 	x"30"  -- 	and		    -- 	A and B		       -- 	0
-- 	x"40"  -- 	or		    -- 	A or B		       -- 	0
-- 	x"50"  -- 	not		    -- 	not A		       --	0
--	x"70"  --	swap		--	B		           --	A
----------------------------------------------------------------------------------------------------

-- Bibliotecas
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

-- Entidade e portas
ENTITY ALU IS
	PORT	(a, b: IN signed (7 downto 0);
		    aluOp: IN std_logic_vector (7 downto 0);
          	result_lsb, result_msb: OUT signed (7 downto 0));
END ENTITY ALU;

architecture LOGIC of ALU is
	signal temp : signed (15 downto 0);
	signal lessThan, equal : signed (7 downto 0);
begin
	temp <= a * b;
    lessThan <= x"01" when (a<b) else x"00";
    equal <= x"01" when (a=b) else x"00";
        
	WITH aluOp SELECT
	result_lsb <=       lessThan             when x"03",
	                    equal                when x"04",
	                    a+b 		         when x"10",
                        temp(7 downto 0)	 when x"20",
                        a and b			     when x"30",
			 	        a or b 			     when x"40",
			 	        not a	 		     when x"50",
     		 	        b	 		         when x"70",
				        (others =>'0')       when others;
	
	WITH aluOp SELECT	
        result_msb <=   temp (15 downto 8)  when x"20",
                        a	 		        when x"70",
				        (others => '0')     when others;
				            
end architecture LOGIC;