if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
    gridXLen = 10
    gridYLen = 18


    function reset()
        inert = {}
        for y = 1, gridYLen do
            inert[y] = {}
            for x = 1, gridXLen do
                inert[y][x] = ' '
            end
        end

        newSequence()
        newPiece()
        timer = 0
    end
    pieceStructures = {
        {
            {
                {' ', ' ', ' ', ' '},
                {'i', 'i', 'i', 'i'},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'i', ' ', ' '},
                {' ', 'i', ' ', ' '},
                {' ', 'i', ' ', ' '},
                {' ', 'i', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {' ', 'o', 'o', ' '},
                {' ', 'o', 'o', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'j', 'j', 'j', ' '},
                {' ', ' ', 'j', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'j', ' ', ' '},
                {' ', 'j', ' ', ' '},
                {'j', 'j', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {'j', ' ', ' ', ' '},
                {'j', 'j', 'j', ' '},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'j', 'j', ' '},
                {' ', 'j', ' ', ' '},
                {' ', 'j', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'l', 'l', 'l', ' '},
                {'l', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'l', ' ', ' '},
                {' ', 'l', ' ', ' '},
                {' ', 'l', 'l', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', ' ', 'l', ' '},
                {'l', 'l', 'l', ' '},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {'l', 'l', ' ', ' '},
                {' ', 'l', ' ', ' '},
                {' ', 'l', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'t', 't', 't', ' '},
                {' ', 't', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 't', ' ', ' '},
                {' ', 't', 't', ' '},
                {' ', 't', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 't', ' ', ' '},
                {'t', 't', 't', ' '},
                {' ', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 't', ' ', ' '},
                {'t', 't', ' ', ' '},
                {' ', 't', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {' ', 's', 's', ' '},
                {'s', 's', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {'s', ' ', ' ', ' '},
                {'s', 's', ' ', ' '},
                {' ', 's', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
        {
            {
                {' ', ' ', ' ', ' '},
                {'z', 'z', ' ', ' '},
                {' ', 'z', 'z', ' '},
                {' ', ' ', ' ', ' '},
            },
            {
                {' ', 'z', ' ', ' '},
                {'z', 'z', ' ', ' '},
                {'z', ' ', ' ', ' '},
                {' ', ' ', ' ', ' '},
            },
        },
    }
    
    function newPiece()
        pieceX = 3
        pieceY = 0
        pieceRotation = 1
        pieceType = table.remove(sequence)
        if #sequence == 0 then
            newSequence()
        end
    end

    function canPieceMove(testX, testY, testRotation)
        for i = 1, 4 do
            for j = 1,4 do
                local testBlockX = testX + i
                local testBlockY = testY + j
                if pieceStructures[pieceType][testRotation][i][j] ~= ' ' and (
                testBlockX < 1 
                or testBlockX > gridXLen 
                or testBlockY > gridYLen 
                or inert[testBlockY][testBlockX] ~= ' '
                ) then
                    return false
                end
            end 
        end
        return true
    end

    function newSequence()
        sequence = {}
        for pieceTypeIndex = 1, #pieceStructures do
            local position = love.math.random(#sequence + 1)
            table.insert(
                sequence,
                position,
                pieceTypeIndex
            )
        end
    end

    score = 0
    timeLimit = 1
    scoreLimit = 0
    reset()
end

function love.update(dt)
    timer = timer + dt
    if scoreLimit > 5000 then
        timeLimit = timeLimit - 10 * dt
        scoreLimit = 0
    end

    if timeLimit < 0.1 then
        timeLimit = 0.1
    end
    
    if timer >= timeLimit then
        timer = 0

        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        else
            for i = 1, 4 do
                for j = 1, 4 do
                    local block = pieceStructures[pieceType][pieceRotation][i][j]
                    if block ~= ' ' then
                        inert[pieceY + j][pieceX + i] = block
                    end
                end
            end

            for i = 1, gridYLen do
                local complete = true
                for j = 1, gridXLen do
                    if inert[i][j] == ' ' then
                        complete = false
                        break
                    end
                end
                if complete then
                    score = score + 1000
                    scoreLimit = scoreLimit + 1000
                    for removeY = i, 2, -1 do
                        for removeX = 1, gridXLen do
                            inert[removeY][removeX] = inert[removeY - 1][removeX]
                        end
                    end

                    for removeX = 1, gridXLen do
                        inert[1][removeX] = ' '
                    end
                end
            end

            newPiece()

            if not canPieceMove(pieceX, pieceY, pieceRotation) then
                love.load()
            end
        end
    end
end

function love.draw()
    local function drawBlock(block, i, j)
        local colors = {
            [' '] = {.87, .87, .87},
            i = {.47, .76, .94},
            j = {.93, .91, .42},
            l = {.49, .85, .76},
            o = {.92, .69, .47},
            s = {.83, .54, .93},
            t = {.97, .58, .77},
            z = {.66, .83, .46},
            preview = {.75, .75, .75}
        }
        local color = colors[block]
        love.graphics.setColor(color)
        local blockSize = 20
        local blockDrawSize = blockSize - 1

        love.graphics.rectangle(
            'fill',
            (j - 1) * blockSize,
            (i - 1) * blockSize,
            blockDrawSize,
            blockDrawSize
        )
    end

   local offSetX = 2
   local offSetY = 8

    for i = 1, gridYLen do
        for j = 1, gridXLen do
            drawBlock(inert[i][j], i + offSetX, j + offSetY)
        end
    end

    for i = 1, 4 do
        for j = 1, 4 do
            local block = pieceStructures[pieceType][pieceRotation][i][j]
            if block ~= ' ' then
                drawBlock(block, j + pieceY + offSetX, i + pieceX + offSetY)
            end
        end
    end

    for y = 1, 4 do
        for x = 1, 4 do
            local block = pieceStructures[sequence[#sequence]][1][y][x]
            if block ~= ' ' then
                drawBlock('preview', x + 5, y + 1)
            end
        end
    end
    love.graphics.print("Score: "..score, 160, 5)
    love.graphics.print("Press Z to Rotate", 20, 25)
    love.graphics.print("Press X to Rotate", 20, 45)
    love.graphics.print("Press C to Drop", 20, 65)
end

function love.keypressed(key)
    if key == 'x' then
        local testRotation = pieceRotation + 1
        if testRotation > #pieceStructures[pieceType] then
            testRotation = 1
        end
        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end
    elseif key == 'z' then
        local testRotation = pieceRotation - 1
        if testRotation < 1 then
            testRotation = #pieceStructures[pieceType]
        end

        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end

    elseif key == 'left' then
        if canPieceMove(pieceX - 1, pieceY, pieceRotation) then
            pieceX = pieceX - 1
        end

    elseif key == 'right' then
        if canPieceMove(pieceX + 1, pieceY, pieceRotation) then
            pieceX = pieceX + 1
        end
    elseif key == 'c' then
        while canPieceMove(pieceX, pieceY + 1, pieceRotation) do
            pieceY = pieceY + 1
            timer = timeLimit
        end
    elseif key == 'down' then
        if canPieceMove(pieceX, pieceY + 1, pieceRotation) then
            pieceY = pieceY + 1
        end
    end
end

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end