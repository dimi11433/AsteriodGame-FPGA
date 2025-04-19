library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alien_1_graph is
    port (
        clk, reset : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        btnl, btnr, btnc : in std_logic;
        refresh_screen : in std_logic;
        collision : in std_logic;
        active : in std_logic;
        automatic_or_manual : in std_logic;
        alien_missile_x, alien_missile_y : out unsigned(9 downto 0);
        launch_missile : out std_logic;
        alien_on : out std_logic
    );
end entity alien_1_graph;

architecture behavior of alien_1_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant ALIEN_X_SIZE : integer := 24;
    constant ALIEN_Y_SIZE : integer := 16;

    constant ALIEN_DX : integer := 1;

    signal alien_rom_bit : std_logic;

    signal alien_x_start, alien_x_end : unsigned(9 downto 0);
    signal alien_y_top, alien_y_bottom : unsigned(9 downto 0);

    signal alien_x_start_next, alien_y_top_next : unsigned(9 downto 0);

    signal collision_happened : std_logic;

    type T_SHOOT_STATE is (SHOOT_1, SHOOT_2, SHOOT_3, IDLE_1, IDLE_2, IDLE_3, IDLE_4, IDLE_5, IDLE_6, IDLE_7, IDLE_8);
    signal shoot_state       : T_SHOOT_STATE := SHOOT_1;
    signal shoot_state_next  : T_SHOOT_STATE;

    -- alien image
    type rom_type_16 is array(0 to 15) of std_logic_vector(0 to 23);
    constant ALIEN_ROM : rom_type_16 := (
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

begin
    -- Determine bitmap bit for current pixel within alien sprite ROM
    alien_rom_bit <= ALIEN_ROM(to_integer(pixel_y(3 downto 0) - alien_y_top(3 downto 0)))(to_integer(pixel_x(4 downto 0) - alien_x_start(4 downto 0)));

    -- Render alien pixel: check horizontal/vertical bounds, ROM bit, and active flag
    alien_on <= '1' when (pixel_x >= alien_x_start and pixel_x <= alien_x_end) and
        (pixel_y >= alien_y_top and pixel_y <= alien_y_bottom) and (alien_rom_bit = '1') and (active = '1') else
        '0';

    -- Set the right and bottom for all the objects
    alien_x_end <= alien_x_start + ALIEN_X_SIZE - 1;
    alien_y_bottom <= alien_y_top + ALIEN_Y_SIZE - 1;

    -- set the alien missile position
    alien_missile_x <= alien_x_start + (ALIEN_X_SIZE / 2) - 2;
    alien_missile_y <= alien_y_top + 4;

    -- Alien horizontal movement logic: automatic wrap or manual control based on switches
    process (alien_x_start)
    begin
        -- Automatic mode: move right by ALIEN_DX and wrap at right edge
        if automatic_or_manual = '0' then
            if alien_x_start < to_unsigned(SCREEN_WIDTH - ALIEN_X_SIZE, 10) then
                alien_x_start_next <= alien_x_start + ALIEN_DX;
            else
                alien_x_start_next <= to_unsigned(0, 10);
            end if;
        else
            -- Manual mode: respond to left/right button presses
            if (btnl = '1') and (alien_x_start > to_unsigned(0, 10)) then
                -- Move left if left button pressed and not at left screen edge
                alien_x_start_next <= alien_x_start - ALIEN_DX;
            elsif (btnr = '1') and (alien_x_start < to_unsigned(SCREEN_WIDTH - ALIEN_X_SIZE, 10)) then
                -- Move right if right button pressed and not at right screen edge
                alien_x_start_next <= alien_x_start + ALIEN_DX;
            else
                alien_x_start_next <= alien_x_start;
            end if;
        end if;

    end process;

    -- Initialization and update: center alien on reset, handle refresh-based movement, and respawn on collision
    process (clk, reset)
    begin
        -- Reset state: center alien horizontally and set top position, clear collision flag
        if (reset = '1') then
            alien_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ALIEN_X_SIZE / 2, 10);
            alien_y_top <= to_unsigned(10, 10);
            collision_happened <= '0';
        elsif (rising_edge(clk)) then
            -- On clock edge: check refresh tick then update position or respawn, and capture collision events
            if (refresh_screen = '1') then
                -- On refresh tick: move to next position or respawn at center after collision
                if (collision_happened = '1') then
                    alien_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ALIEN_X_SIZE / 2, 10);
                    collision_happened <= '0';
                else
                    alien_x_start <= alien_x_start_next;
                end if;
            end if;

            -- Capture collision event: mark for respawn on next refresh
            if (collision = '1') then
                collision_happened <= '1';
            end if;
        end if;
    end process;

    -- Alien missile launch FSM using shoot_state
    -- Combinational next-state and output logic
    process(shoot_state)
    begin
        case shoot_state is
            when SHOOT_1 =>
                shoot_state_next <= SHOOT_2;
            when SHOOT_2 =>
                shoot_state_next <= SHOOT_3;
            when SHOOT_3 =>
                shoot_state_next <= IDLE_1;
            when IDLE_1 =>
                shoot_state_next <= IDLE_2;
            when IDLE_2 =>
                shoot_state_next <= IDLE_3;
            when IDLE_3 =>
                shoot_state_next <= IDLE_4;
            when IDLE_4 =>
                shoot_state_next <= IDLE_5;
            when IDLE_5 =>
                shoot_state_next <= IDLE_6;
            when IDLE_6 =>
                shoot_state_next <= IDLE_7;
            when IDLE_7 =>
                shoot_state_next <= IDLE_8;
            when IDLE_8 =>
                shoot_state_next <= SHOOT_1;
            when others =>
                shoot_state_next <= SHOOT_1;
        end case;
    end process;

    -- Synchronous state register update on refresh tick
    process(clk, reset)
    begin
        if reset = '1' then
            shoot_state <= SHOOT_1;
            launch_missile <= '0';
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                shoot_state <= shoot_state_next;
                if (automatic_or_manual = '0') then
                    -- Automatic mode: launch missile if in shooting state
                    if (shoot_state_next = SHOOT_1) or (shoot_state_next = SHOOT_2) or (shoot_state_next = SHOOT_3) then
                        launch_missile <= '1';
                    else
                        launch_missile <= '0';
                    end if;
                else
                    -- Manual mode: launch missile if in shooting state
                    if (btnc = '1') then
                        launch_missile <= '1';
                    else
                        launch_missile <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end behavior;