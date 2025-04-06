LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY vga_sync IS
    PORT (
        clk, reset : IN STD_LOGIC;
        hsync, vsync, comp_sync : OUT STD_LOGIC;
        video_on, p_tick : OUT STD_LOGIC;
        pixel_x, pixel_y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END vga_sync;

ARCHITECTURE arch OF vga_sync IS
    CONSTANT HD : INTEGER := 640; -- horizontal display
    CONSTANT HF : INTEGER := 16; -- hsync front porch
    CONSTANT HB : INTEGER := 48; -- hsync back porch
    CONSTANT HR : INTEGER := 96; -- hsync retrace
    CONSTANT VD : INTEGER := 480; -- vertical display
    CONSTANT VF : INTEGER := 11; -- vsync front porch
    CONSTANT VB : INTEGER := 31; -- vsync back porch
    CONSTANT VR : INTEGER := 2; -- vsync retrace
    -- clk divider
    SIGNAL clk_div_reg, clk_div_next : unsigned(1 DOWNTO 0);
    -- sync counters
    SIGNAL v_cnt_reg, v_cnt_next : unsigned(9 DOWNTO 0);
    SIGNAL h_cnt_reg, h_cnt_next : unsigned(9 DOWNTO 0);
    -- output buffers
    SIGNAL v_sync_reg, h_sync_reg : STD_LOGIC;
    SIGNAL v_sync_next, h_sync_next : STD_LOGIC;
    SIGNAL h_sync_delay1_reg, h_sync_delay2_reg : STD_LOGIC;
    SIGNAL h_sync_delay1_next, h_sync_delay2_next : STD_LOGIC;
    SIGNAL v_sync_delay1_reg, v_sync_delay2_reg : STD_LOGIC;
    SIGNAL v_sync_delay1_next, v_sync_delay2_next : STD_LOGIC;
    -- status signal
    SIGNAL h_end, v_end, pixel_tick : STD_LOGIC;
BEGIN
    -- ===============================================
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            clk_div_reg <= to_unsigned(0, 2);
            v_cnt_reg <= (OTHERS => '0');
            h_cnt_reg <= (OTHERS => '0');
            v_sync_reg <= '0';
            h_sync_reg <= '0';
            v_sync_delay1_reg <= '0';
            h_sync_delay1_reg <= '0';
            v_sync_delay2_reg <= '0';
            h_sync_delay2_reg <= '0';
        ELSIF (rising_edge(clk)) THEN
            clk_div_reg <= clk_div_next;
            v_cnt_reg <= v_cnt_next;
            h_cnt_reg <= h_cnt_next;
            v_sync_reg <= v_sync_next;
            h_sync_reg <= h_sync_next;
            -- Add two cycles of delay for DAC pipeline.
            v_sync_delay1_reg <= v_sync_delay1_next;
            h_sync_delay1_reg <= h_sync_delay1_next;
            v_sync_delay2_reg <= v_sync_delay2_next;
            h_sync_delay2_reg <= h_sync_delay2_next;
        END IF;
    END PROCESS;
    -- Pipeline registers
    v_sync_delay1_next <= v_sync_reg;
    h_sync_delay1_next <= h_sync_reg;
    v_sync_delay2_next <= v_sync_delay1_reg;
    h_sync_delay2_next <= h_sync_delay1_reg;
    -- Generate a 25 MHz enable tick from 100 MHz clock
    clk_div_next <= clk_div_reg + 1;
    pixel_tick <= '1' WHEN clk_div_reg = to_unsigned(3, 2) ELSE
        '0';
    -- h_end and v_end depend on constants above
    h_end <= '1' WHEN h_cnt_reg = (HD + HF + HB + HR - 1) ELSE
        '0';
    v_end <= '1' WHEN v_cnt_reg = (VD + VF + VB + VR - 1) ELSE
        '0';
    -- mod-800 horz sync cnter for 640 pixels
    -- =======================================
    PROCESS (h_cnt_reg, h_end, pixel_tick)
    BEGIN
        IF (pixel_tick = '1') THEN
            IF (h_end = '1') THEN
                h_cnt_next <= (OTHERS => '0');
            ELSE
                h_cnt_next <= h_cnt_reg + 1;
            END IF;
        ELSE
            h_cnt_next <= h_cnt_reg;
        END IF;
    END PROCESS;
    -- mod-525 vertical sync cnter for 480 pixels
    -- ===========================================
    PROCESS (v_cnt_reg, h_end, v_end, pixel_tick)
    BEGIN
        IF (pixel_tick = '1' AND h_end = '1') THEN
            IF (v_end = '1') THEN
                v_cnt_next <= (OTHERS => '0');
            ELSE
                v_cnt_next <= v_cnt_reg + 1;
            END IF;
        ELSE
            v_cnt_next <= v_cnt_reg;
        END IF;
    END PROCESS;
    -- horz and vert sync, buffered to avoid glitch
    h_sync_next <= '0' WHEN (h_cnt_reg >= (HD + HF)) AND
        (h_cnt_reg <= (HD + HF + HR - 1)) ELSE
        '1';
    v_sync_next <= '0' WHEN (v_cnt_reg >= (VD + VF)) AND
        (v_cnt_reg <= (VD + VF + VR - 1)) ELSE
        '1';
    -- video on/off (640)
    video_on <= '1' WHEN (h_cnt_reg < HD) AND
        (v_cnt_reg < VD) ELSE
        '0';
    -- output signals
    hsync <= h_sync_delay2_reg;
    vsync <= v_sync_delay2_reg;
    pixel_x <= STD_LOGIC_VECTOR(h_cnt_reg);
    pixel_y <= STD_LOGIC_VECTOR(v_cnt_reg);
    p_tick <= pixel_tick;
    -- comp sync signal generation
    comp_sync <= h_sync_reg XOR v_sync_reg;
END arch;