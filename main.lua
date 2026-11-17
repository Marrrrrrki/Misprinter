
-- Misprinter v0.3.0
-- Displays the next 5 cards in the draw pile.

print("[Misprinter] Loaded!")

local CARD_COUNT = 5

local function get_next_cards()
    if not G or not G.deck or not G.deck.cards then
        return {}
    end

    local cards = {}
    local deck = G.deck.cards

    -- The last card in the deck is the next one drawn.
    for i = #deck, math.max(1, #deck - CARD_COUNT + 1), -1 do
        table.insert(cards, deck[i])
    end

    return cards
end

local function draw_card(card, x, y, w, h)
    local lg = love.graphics

    if not card then return end

    local front = card.children and card.children.front

    if front and front.atlas and front.atlas.image and front.sprite then
        local image = front.atlas.image
        local _, _, source_w, source_h = front.sprite:getViewport()

        if source_w and source_h and source_w > 0 and source_h > 0 then
            lg.setColor(1, 1, 1, 1)

            lg.draw(
                image,
                front.sprite,
                x,
                y,
                0,
                w / source_w,
                h / source_h
            )

            return
        end
    end

    -- Fallback if the artwork isn't available.
    lg.setColor(1, 1, 1, 1)
    lg.rectangle("fill", x, y, w, h)

    lg.setColor(0.1, 0.1, 0.1, 1)
    lg.printf(
        tostring(card.base and card.base.value or "?"),
        x,
        y + h / 2 - 8,
        w,
        "center"
    )
end

local function draw_misprinter()
    if not (love and love.graphics and G and G.deck) then
        return
    end

    local cards = get_next_cards()
    if #cards == 0 then return end

    local lg = love.graphics

    local screen_w = lg.getWidth()

    local card_w = 48
    local card_h = 66
    local spacing = 6

    local padding = 10
    local panel_w = padding * 2
        + CARD_COUNT * card_w
        + (CARD_COUNT - 1) * spacing

    local panel_h = card_h + 42

    local x = screen_w - panel_w - 20
    local y = 25

    lg.push("all")

    -- Background panel
    lg.setColor(0.035, 0.04, 0.055, 0.94)
    lg.rectangle(
        "fill",
        x,
        y,
        panel_w,
        panel_h,
        8,
        8
    )

    -- Border
    lg.setColor(0.78, 0.72, 0.52, 1)
    lg.setLineWidth(2)
    lg.rectangle(
        "line",
        x,
        y,
        panel_w,
        panel_h,
        8,
        8
    )

    -- Heading
    lg.setColor(0.95, 0.88, 0.68, 1)
    lg.printf(
        "MISPRINTER - NEXT 5",
        x,
        y + 7,
        panel_w,
        "center"
    )

    -- Draw the next five cards
    for i = 1, CARD_COUNT do
        local card = cards[i]

        if card then
            local card_x = x + padding + (i - 1) * (card_w + spacing)
            local card_y = y + 29

            draw_card(
                card,
                card_x,
                card_y,
                card_w,
                card_h
            )
        end
    end

    lg.pop()
end

-- Hook the game's drawing function.
if Game and type(Game.draw) == "function" then
    local original_draw = Game.draw

    function Game:draw(...)
        original_draw(self, ...)
        draw_misprinter()
    end

    print("[Misprinter] Five-card preview hook installed!")
else
    print("[Misprinter] ERROR: Game.draw unavailable!")
end
