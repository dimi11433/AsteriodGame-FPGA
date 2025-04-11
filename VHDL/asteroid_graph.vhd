library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asteroid_graph is
    port (
        clk, reset : in std_logic;
        pixel_tick : in std_logic;
        video_on : in std_logic;
        pixel_x : in std_logic_vector(9 downto 0);
        pixel_y : in std_logic_vector(9 downto 0);
        btnl, btnr : in std_logic;
        btnu, btnd : in std_logic;
        btnc : in std_logic;
        graph_rgb : out std_logic_vector(2 downto 0);
    );
end asteroid_graph;

architecture asteroid_arch of asteroid_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant ALIEN_SIZE : integer := 24;
    constant SPACESHIP_X_SIZE : integer := 16;
    constant SPACESHIP_Y_SIZE : integer := 24;
    constant ASTEROID_SIZE : integer := 8;

    signal pix_x, pix_y : unsigned(9 downto 0);
    signal alien_rom_bit, spaceship_rom_bit, asteroid_rom_bit : std_logic;

    signal alien_x_start, alien_x_end : unsigned(9 downto 0);
    signal alien_y_top, alien_y_bottom : unsigned(9 downto 0);

    signal spaceship_x_start, spaceship_x_end : unsigned(9 downto 0);
    signal spaceship_y_top, spaceship_y_bottom : unsigned(9 downto 0);

    signal asteroid_x_start, asteroid_x_end : unsigned(9 downto 0);
    signal asteroid_y_top, asteroid_y_bottom : unsigned(9 downto 0);

    -- next start positions for the objects
    signal alien_x_start_next, alien_y_top_next : unsigned(9 downto 0);
    signal spaceship_x_start_next, spaceship_y_top_next : unsigned(9 downto 0);
    signal asteroid_x_start_next, asteroid_y_top_next : unsigned(9 downto 0);

    signal alien_on, spaceship_on, asteroid_on : std_logic;
    signal alien_color, spaceship_color, asteroid_color : std_logic_vector(2 downto 0);

    signal refresh_screen : std_logic;

    -- alien image
    type rom_type_24 is array(0 to 23) of std_logic_vector(0 to 23);
    constant ALIEN_ROM : rom_type_24 := (
        "000000110000000011000000",
        "000000001110011100000000",
        "000000001110011100000000",
        "011000111111111111000110",
        "011000111111111111000110",
        "011000111111111111000110",
        "011000110001100011000110",
        "011000110001100011000110",
        "000111111111111111111000",
        "000111111111111111111000",
        "000111111111111111111000",
        "000000111111111111000000",
        "000000111111111111000000",
        "000000001110011100000000",
        "000000001110011100000000",
        "000000001110011100000000"
    );
    -- spaceship image
    type rom_type_16 is array(0 to 23) of std_logic_vector(0 to 15);
    constant SPACESHIP_ROM : rom_type_16 := (
        "0000000100000000", -- tip
        "0000001110000000",
        "0000011111000000",
        "0000111111110000",
        "0011111111111100", -- body starts
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100", -- body ends
        "0111111111111110", -- exhaust/flame begins
        "1111111111111111",
        "0111111111111110",
        "0011111111111100" -- exhaust/flame ends
    );
    -- asteroid image
    type rom_type_8 is array(0 to 7) of std_logic_vector(0 to 7);
    constant ASTEROID_ROM : rom_type_8 := (
        "00111100",
        "01111110",
        "11111111",
        "11111111",
        "11111111",
        "11111111",
        "01111110",
        "00111100"
    );

begin
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);

    alien_rom_bit <= ALIEN_ROM(to_integer(pix_y) - to_integer(alien_y_top))(to_integer(pix_x) - to_integer(alien_x_start));

    spaceship_rom_bit <= SPACESHIP_ROM(to_integer(pix_y) - to_integer(spaceship_y_top))(to_integer(pix_x) - to_integer(spaceship_x_start));

    asteroid_rom_bit <= ASTEROID_ROM(to_integer(pix_y) - to_integer(asteroid_y_top))(to_integer(pix_x) - to_integer(asteroid_x_start));

    alien_on <= '1' when (pix_x >= alien_x_start and pix_x <= alien_x_end) and
        (pix_y >= alien_y_top and pix_y <= alien_y_bottom) and (alien_rom_bit = '1') else
        '0';

    spaceship_on <= '1' when (pix_x >= spaceship_x_start and pix_x <= spaceship_x_end) and
        (pix_y >= spaceship_y_top and pix_y <= spaceship_y_bottom) and (spaceship_rom_bit = '1') else
        '0';

    asteroid_on <= '1' when (pix_x >= asteroid_x_start and pix_x <= asteroid_x_end) and
        (pix_y >= asteroid_y_top and pix_y <= asteroid_y_bottom) and (asteroid_rom_bit = '1') else
        '0';

    alien_color <= "110";
    spaceship_color <= "010"; -- green
    asteroid_color <= "111"; -- white/greyish

    -- Set the right and bottom for all the objects
    alien_x_end <= alien_x_start + ALIEN_SIZE - 1;
    alien_y_bottom <= alien_y_top + ALIEN_SIZE - 1;

    spaceship_x_end <= spaceship_x_start + SPACESHIP_X_SIZE - 1;
    spaceship_y_bottom <= spaceship_y_top + SPACESHIP_Y_SIZE - 1;

    asteroid_x_end <= asteroid_x_start + ASTEROID_SIZE - 1;
    asteroid_y_bottom <= asteroid_y_top + ASTEROID_SIZE - 1;

    refresh_screen <= '1' when (pix_x = to_unsigned(SCREEN_WIDTH - 1, 10) and
        pix_y = to_unsigned(SCREEN_HEIGHT - 1, 10) and pixel_tick = '1') else
        '0';
    -- at reset, set the initial positions of the objects
    process (clk, reset)
    begin
        if reset = '1' then
            alien_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ALIEN_SIZE / 2, 10);
            alien_y_top <= to_unsigned(10, 10);

            spaceship_x_start <= to_unsigned(SCREEN_WIDTH / 2 - SPACESHIP_X_SIZE / 2, 10);
            spaceship_y_top <= to_unsigned(SCREEN_HEIGHT - 10 - SPACESHIP_Y_SIZE, 10);

            asteroid_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ASTEROID_SIZE / 2, 10);
            asteroid_y_top <= to_unsigned(SCREEN_HEIGHT / 2 - ASTEROID_SIZE / 2, 10);
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                alien_x_start <= alien_x_start_next;
                alien_y_top <= alien_y_top_next;

                spaceship_x_start <= spaceship_x_start_next;
                spaceship_y_top <= spaceship_y_top_next;

                asteroid_x_start <= asteroid_x_start_next;
                asteroid_y_top <= asteroid_y_top_next;
            end if;
        end if;
    end process;

    -- update the spaceship position based on button presses
    process (btnl, btnr, btnu, btnd)
        spaceship_x_start_next <= spaceship_x_start;
        spaceship_y_top_next <= spaceship_y_top;
    begin
        if (btnl = '1') and (spaceship_x_start > 0) then
            spaceship_x_start_next <= spaceship_x_start - 1;
        elsif (btnr = '1') and (spaceship_x_end < SCREEN_WIDTH - 1) then
            spaceship_x_start_next <= spaceship_x_start + 1;
        end if;
        if (btnu = '1') and (spaceship_y_top > 0) then
            spaceship_y_top_next <= spaceship_y_top - 1;
        elsif (btnd = '1') and (spaceship_y_bottom < SCREEN_HEIGHT - 1) then
            spaceship_y_top_next <= spaceship_y_top + 1;
        end if;
    end process;

    process (video_on, alien_on, spaceship_on, asteroid_on)
    begin
        if video_on = '1' then
            if alien_on = '1' then
                graph_rgb <= alien_color;
            elsif spaceship_on = '1' then
                graph_rgb <= spaceship_color;
            elsif asteroid_on = '1' then
                graph_rgb <= asteroid_color;
            else
                graph_rgb <= "000"; -- black
            end if;
        else
            graph_rgb <= "000"; -- black
        end if;
    end process;
end asteroid_arch;