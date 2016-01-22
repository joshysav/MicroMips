library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 --------------------------------------------------------------------------------------
entity alu is
  
  port (
    op_a     : in  std_logic_vector(31 downto 0);
    op_b     : in  std_logic_vector(31 downto 0);
    fn_class : in  std_logic_vector(1 downto 0);
    logic_fn : in  std_logic_vector(1 downto 0);
    arith_fn : in  std_logic;
    result   : out std_logic_vector(31 downto 0);
    ovfl     : out std_logic);

end entity alu;
 --------------------------------------------------------------------------------------

architecture rtl of alu is
  signal result_s : std_logic_vector(31 downto 0);
  signal ovfl_s   : std_logic;
begin  -- architecture rtl
 --------------------------------------------------------------------------------------
  -- Function class
  -- 00 : LUI
  -- 01 : Set less than
  -- 10 : Arithmetic
  -- 11 : Logic
  --
  -- Arithmetic:
  -- 0 : Add
  -- 1 : Subtract
  --
  -- Logic:
  -- 00 : AND
  -- 01 : OR
  -- 10 : XOR
  -- 11 : NOR
 --------------------------------------------------------------------------------------
  update_result : process (op_a, op_b, fn_class, logic_fn, arith_fn)
  begin  -- process update_result
    case fn_class is
      -- Lui
      when "00" =>
        result_s <= op_b(15 downto 0) & "0000000000000000";
      -- Set less than
      when "01" =>
        if signed(op_a) < signed(op_b) then
          result_s <= std_logic_vector(to_unsigned(1, 32));
        else
          result_s <= (others => '0');
        end if;
      -- Arithmetic
      when "10" =>
        if(arith_fn = '0') then
          result_s <= std_logic_vector(signed(op_a) + signed(op_b));
        else
          result_s <= std_logic_vector(signed(op_a) - signed(op_b));
        end if;
      -- Logic
      when "11" =>
        if (logic_fn = "00") then
          result_s <= op_a and op_b;
        elsif (logic_fn = "01") then
          result_s <= op_a or op_b;
        elsif (logic_fn = "10")  then
          result_s <= op_a xor op_b;
        elsif (logic_fn = "11") then
          result_s <= op_a nor op_b;
        else
          result_s <= (others => '0');
        end if;
      when others =>
        result_s <= (others => '0');
    end case;
  end process update_result;

 --------------------------------------------------------------------------------------
  -- If two positive numbers are added then we expect positive result,
  -- otherwise overflow.
  -- If two negative numbers are added the we expect negative result, otherwise
  -- overflow.
  -- If two numbers are subtracted and first is positive and second negative we
  -- expect result to be positive, otherwise overflow.
  -- If two numbers are subtracted and first is negative and second positive we
  -- expect negative result, otherwise overflow.
  --------------------------------------------------------------------------------------
  -- ============       ============
  -- ADD                SUBTR
  -- ============       ============
  -- | A B R | O |      | A B R | O |
  -- |-------|---|      |-------|---|
  -- | 0 0 0 | 0 |      | 0 0 0 | 0 |
  -- | 0 0 1 | 1 |      | 0 0 1 | 0 |
  -- | 0 1 0 | 0 |      | 0 1 0 | 0 |   
  -- | 0 1 1 | 0 |      | 0 1 1 | 1 |
  -- | 1 0 0 | 0 |      | 1 0 0 | 1 |
  -- | 1 0 1 | 0 |      | 1 0 1 | 0 |
  -- | 1 1 0 | 1 |      | 1 1 0 | 0 |
  -- | 1 1 1 | 0 |      | 1 1 1 | 0 |
  --
  -- ADD OVERFLOW = (!A and !B and R) or (A and B and !R)
  -- SUB OVERFLOW = (!A and B and R) or (A and !B and !R)
  --------------------------------------------------------------------------------------
  update_ovfl : process (op_a, op_b, arith_fn, fn_class, result_s)
  begin  -- process update_ovfl
    if((arith_fn = '0' and op_a(31) = '0' and op_b(31) = '0' and result_s(31) = '1') or
       (arith_fn = '0' and op_a(31) = '1' and op_b(31) = '1' and result_s(31) = '0')) then
      ovfl_s <= '1';
    elsif((arith_fn = '1' and op_a(31) = '0' and op_b(31) = '1' and result_s(31) = '1') or
          (arith_fn = '1' and op_a(31) = '1' and op_b(31) = '0' and result_s(31) = '0')) then
      ovfl_s <= '1';
    else
      ovfl_s <= '0';
    end if;
    
  end process update_ovfl;

  result <= result_s;
  ovfl   <= ovfl_s;
end architecture rtl;

