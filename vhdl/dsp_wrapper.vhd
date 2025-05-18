
Library UNISIM;
use UNISIM.vcomponents.all;
library ieee;
use ieee.std_logic_1164.all;
use work.array_types.all;
use work.basic_pkg.all;

entity dsp_wrapper is
  generic (
    ALUMODE         : std_logic_vector(3 downto 0);
    CARRYINSEL      : std_logic_vector(2 downto 0);
    INMODE          : std_logic_vector(4 downto 0);
    OPMODE          : std_logic_vector(8 downto 0);

    AMULTSEL        : string := "A";
    A_INPUT         : string := "DIRECT";
    BMULTSEL        : string := "B";
    B_INPUT         : string := "DIRECT";
    PREADDINSEL     : string := "A";

    ACASCREG        : natural:= 1;    
    ADREG           : natural:= 1;
    ALUMODEREG      : natural:= 1;      
    AREG            : natural:= 1;
    BCASCREG        : natural:= 1;    
    BREG            : natural:= 1;
    CARRYINREG      : natural:= 1;      
    CARRYINSELREG   : natural:= 1;        
    CREG            : natural:= 1;
    DREG            : natural:= 1;
    INMODEREG       : natural:= 1;    
    MREG            : natural:= 1;
    OPMODEREG       : natural:= 1;    
    PREG            : natural:= 1
      
  );
  port (
    clk_i           : in std_logic;
    reset_i         : in std_logic;
    ce_i            : in std_logic:='1';
    a_i             : in std_logic_vector(29 downto 0):= (others =>'0');
    b_i             : in std_logic_vector(17 downto 0):= (others =>'0');
    c_i             : in std_logic_vector(47 downto 0):= (others =>'0');
    d_i             : in std_logic_vector(26 downto 0):= (others =>'0');
    p_o             : out std_logic_vector(47 downto 0);
    carry_i         : in std_logic := '0';
    carry_o         : out std_logic_vector(3 downto 0);
    a_cas_i         : in std_logic_vector(29 downto 0):= (others =>'0');
    b_cas_i         : in std_logic_vector(17 downto 0):= (others =>'0');
    c_cas_i         : in std_logic_vector(47 downto 0):= (others =>'0');
    p_cas_i         : in std_logic_vector(47 downto 0):= (others =>'0');
    a_cas_o         : out std_logic_vector(29 downto 0);
    b_cas_o         : out std_logic_vector(17 downto 0);
    c_cas_o         : out std_logic_vector(47 downto 0);
    p_cas_o         : out std_logic_vector(47 downto 0);
    carry_cas_o     : out std_logic;
    carry_cas_i     : in std_logic:= '0';
    multi_sign_cas_o    : out std_logic;
    multi_sign_cas_i    : in std_logic:= '0';
    ctrl_o          : out std_logic_vector(3 downto 0)
        
  );
end entity;
architecture Behavioral of dsp_wrapper is

  begin
   -- DSP48E2: 48-bit Multi-Functional Arithmetic Block

   i_DSP48E2 : DSP48E2
   generic map (
      -- Feature Control Attributes: Data Path Selection
      AMULTSEL => AMULTSEL,                   -- Selects A input to multiplier (A, AD)
      A_INPUT => A_INPUT,               -- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      BMULTSEL => BMULTSEL,                   -- Selects B input to multiplier (AD, B)
      B_INPUT => B_INPUT,               -- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      PREADDINSEL => PREADDINSEL,                -- Selects input to pre-adder (A, B)
      RND => X"000000000000",            -- Rounding Constant
      USE_MULT => "MULTIPLY",            -- Select multiplier usage (DYNAMIC, MULTIPLY, NONE)
      USE_SIMD => "ONE48",               -- SIMD selection (FOUR12, ONE48, TWO24)
      USE_WIDEXOR => "FALSE",            -- Use the Wide XOR function (FALSE, TRUE)
      XORSIMD => "XOR24_48_96",          -- Mode of operation for the Wide XOR (XOR12, XOR24_48_96)
      -- Pattern Detector Attributes: Pattern Detection Configuration
      AUTORESET_PATDET => "NO_RESET",    -- NO_RESET, RESET_MATCH, RESET_NOT_MATCH
      AUTORESET_PRIORITY => "RESET",     -- Priority of AUTORESET vs. CEP (CEP, RESET).
      MASK => X"3fffffffffff",           -- 48-bit mask value for pattern detect (1=ignore)
      PATTERN => X"000000000000",        -- 48-bit pattern match for pattern detect
      SEL_MASK => "MASK",                -- C, MASK, ROUNDING_MODE1, ROUNDING_MODE2
      SEL_PATTERN => "PATTERN",          -- Select pattern value (C, PATTERN)
      USE_PATTERN_DETECT => "NO_PATDET", -- Enable pattern detect (NO_PATDET, PATDET)
      -- Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
      IS_ALUMODE_INVERTED => "0000",     -- Optional inversion for ALUMODE
      IS_CARRYIN_INVERTED => '0',        -- Optional inversion for CARRYIN
      IS_CLK_INVERTED => '0',            -- Optional inversion for CLK
      IS_INMODE_INVERTED => "00000",     -- Optional inversion for INMODE
      IS_OPMODE_INVERTED => "000000000", -- Optional inversion for OPMODE
      IS_RSTALLCARRYIN_INVERTED => '0',  -- Optional inversion for RSTALLCARRYIN
      IS_RSTALUMODE_INVERTED => '0',     -- Optional inversion for RSTALUMODE
      IS_RSTA_INVERTED => '0',           -- Optional inversion for RSTA
      IS_RSTB_INVERTED => '0',           -- Optional inversion for RSTB
      IS_RSTCTRL_INVERTED => '0',        -- Optional inversion for RSTCTRL
      IS_RSTC_INVERTED => '0',           -- Optional inversion for RSTC
      IS_RSTD_INVERTED => '0',           -- Optional inversion for RSTD
      IS_RSTINMODE_INVERTED => '0',      -- Optional inversion for RSTINMODE
      IS_RSTM_INVERTED => '0',           -- Optional inversion for RSTM
      IS_RSTP_INVERTED => '0',           -- Optional inversion for RSTP
      -- Register Control Attributes: Pipeline Register Configuration
      ACASCREG => ACASCREG,                     -- Number of pipeline stages between A/ACIN and ACOUT (0-2)
      ADREG => ADREG,                        -- Pipeline stages for pre-adder (0-1)
      ALUMODEREG => ALUMODEREG,                   -- Pipeline stages for ALUMODE (0-1)
      AREG => AREG,                         -- Pipeline stages for A (0-2)
      BCASCREG => BCASCREG,                     -- Number of pipeline stages between B/BCIN and BCOUT (0-2)
      BREG => BREG,                         -- Pipeline stages for B (0-2)
      CARRYINREG => CARRYINREG,                   -- Pipeline stages for CARRYIN (0-1)
      CARRYINSELREG => CARRYINSELREG,                -- Pipeline stages for CARRYINSEL (0-1)
      CREG => CREG,                         -- Pipeline stages for C (0-1)
      DREG => DREG,                         -- Pipeline stages for D (0-1)
      INMODEREG => INMODEREG,                    -- Pipeline stages for INMODE (0-1)
      MREG => MREG,                         -- Multiplier pipeline stages (0-1)
      OPMODEREG => OPMODEREG,                    -- Pipeline stages for OPMODE (0-1)
      PREG => PREG                          -- Number of pipeline stages for P (0-1)
   )
   port map (
      -- Cascade outputs: Cascade Ports
      ACOUT => a_cas_o,                   -- 30-bit output: A port cascade
      BCOUT => b_cas_o,                   -- 18-bit output: B cascade
      CARRYCASCOUT => carry_cas_o,     -- 1-bit output: Cascade carry
      MULTSIGNOUT => multi_sign_cas_o,       -- 1-bit output: Multiplier sign cascade
      PCOUT => p_cas_o,                   -- 48-bit output: Cascade output
      -- Control outputs: Control Inputs/Status Bits
      OVERFLOW => ctrl_o(0),             -- 1-bit output: Overflow in add/acc
      PATTERNBDETECT => ctrl_o(1), -- 1-bit output: Pattern bar detect
      PATTERNDETECT => ctrl_o(2),   -- 1-bit output: Pattern detect
      UNDERFLOW => ctrl_o(3),           -- 1-bit output: Underflow in add/acc
      -- Data outputs: Data Ports
      CARRYOUT => carry_o,             -- 4-bit output: Carry
      P => p_o,                           -- 48-bit output: Primary data
      XOROUT => open,                 -- 8-bit output: XOR data
      -- Cascade inputs: Cascade Ports
      ACIN => a_cas_i,                     -- 30-bit input: A cascade data
      BCIN => b_cas_i,                     -- 18-bit input: B cascade
      CARRYCASCIN => carry_cas_i,       -- 1-bit input: Cascade carry
      MULTSIGNIN => multi_sign_cas_i,         -- 1-bit input: Multiplier sign cascade
      PCIN => p_cas_i,                     -- 48-bit input: P cascade
      -- Control inputs: Control Inputs/Status Bits
      ALUMODE => ALUMODE,               -- 4-bit input: ALU control
      CARRYINSEL => CARRYINSEL,         -- 3-bit input: Carry select
      CLK => clk_i,                       -- 1-bit input: Clock
      INMODE => INMODE,                 -- 5-bit input: INMODE control
      OPMODE => OPMODE,                 -- 9-bit input: Operation mode
      -- Data inputs: Data Ports
      A => a_i,                           -- 30-bit input: A data
      B => b_i,                           -- 18-bit input: B data
      C => c_i,                           -- 48-bit input: C data
      CARRYIN => carry_i,               -- 1-bit input: Carry-in
      D => d_i,                           -- 27-bit input: D data
      -- Reset/Clock Enable inputs: Reset/Clock Enable Inputs
      CEA1 => ce_i,                     -- 1-bit input: Clock enable for 1st stage AREG
      CEA2 => '1',                     -- 1-bit input: Clock enable for 2nd stage AREG
      CEAD => '1',                     -- 1-bit input: Clock enable for ADREG
      CEALUMODE => '1',                -- 1-bit input: Clock enable for ALUMODE
      CEB1 => ce_i,                     -- 1-bit input: Clock enable for 1st stage BREG
      CEB2 => '1',                     -- 1-bit input: Clock enable for 2nd stage BREG
      CEC => ce_i,                      -- 1-bit input: Clock enable for CREG
      CECARRYIN => '1',                -- 1-bit input: Clock enable for CARRYINREG
      CECTRL => '1',                   -- 1-bit input: Clock enable for OPMODEREG and CARRYINSELREG
      CED => ce_i,                      -- 1-bit input: Clock enable for DREG
      CEINMODE => '1',                 -- 1-bit input: Clock enable for INMODEREG
      CEM => '1',                      -- 1-bit input: Clock enable for MREG
      CEP => '1',                      -- 1-bit input: Clock enable for PREG
      RSTA => reset_i,                  -- 1-bit input: Reset for AREG
      RSTALLCARRYIN => reset_i,         -- 1-bit input: Reset for CARRYINREG
      RSTALUMODE => reset_i,            -- 1-bit input: Reset for ALUMODEREG
      RSTB => reset_i,                  -- 1-bit input: Reset for BREG
      RSTC => reset_i,                  -- 1-bit input: Reset for CREG
      RSTCTRL => reset_i,               -- 1-bit input: Reset for OPMODEREG and CARRYINSELREG
      RSTD => reset_i,                  -- 1-bit input: Reset for DREG and ADREG
      RSTINMODE => reset_i,             -- 1-bit input: Reset for INMODEREG
      RSTM => reset_i,                  -- 1-bit input: Reset for MREG
      RSTP => reset_i                   -- 1-bit input: Reset for PREG
   );

   -- End of DSP48E2_inst instantiation
	
end Behavioral;
