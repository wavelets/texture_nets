-- Decoder-encoder like model with skip-connections 
-- and additional noise inputs.

local nums_3x3down = {16, 32, 64, 128,128}
local nums_1x1 = {4, 4, 4, 4, 4}
local nums_noise={2, 2, 2, 2, 2}
local nums_3x3up = {16, 32, 64, 128,128}
local cur = nil

local act = function() return nn.LeakyReLU(nil, true) end

local cur_depth = nil

local model = nn.Sequential():add(nn.NoiseFill())
local model_tmp = model

input_depth = net_input_depth
for i = 1,#nums_3x3down do
      
        local deeper = nn.Sequential()
        local skip = nn.Sequential()
        local skip_part = nn.Sequential()

        model_tmp:add(nn.Concat(2):add(skip):add(deeper))

        skip_part:add(conv(input_depth, nums_1x1[i], 1))
        skip_part:add(bn(nums_1x1[i]))
        skip_part:add(act())
        
        skip:add(nn.Concat(2):add(nn.GenNoise(nums_noise[i])):add(skip_part))
        
        
        deeper:add(conv(input_depth, nums_3x3down[i], 3,2))
        deeper:add(bn(nums_3x3down[i]))
        deeper:add(act())

        deeper:add(conv(nums_3x3down[i], nums_3x3down[i], 3))
        deeper:add(bn(nums_3x3down[i]))
        deeper:add(act())
      

        deeper_main = nn.Sequential()

        -- k = nil
        if i == #nums_3x3down  then
            k = nums_3x3down[i]
        else
            deeper:add(deeper_main)
            k = nums_3x3up[i+1]
        end

        deeper:add(nn.SpatialUpSamplingNearest(2))

        deeper:add(bn(nums_3x3down[i]))
        skip_part:add(bn(nums_1x1[i]))

        
        model_tmp:add(conv(nums_1x1[i] +  k + nums_noise[i] , nums_3x3up[i], 3,1))
        model_tmp:add(bn(nums_3x3up[i]))
        model_tmp:add(act())

        model_tmp:add(conv(nums_3x3up[i], nums_3x3up[i], 1))
        model_tmp:add(bn(nums_3x3up[i]))
        model_tmp:add(act())
        

        input_depth = nums_3x3down[i]
        model_tmp = deeper_main
end

-- model:add(nn.SpatialUpSamplingNearest(2))
-- model:add(conv(nums_3x3up[1], 16, 3))
-- model:add(bn(16))
-- model:add(act())

-- model:add(conv(16, 3, 1,1))
model:add(conv(nums_3x3up[1], 3, 1,1))

-- print (model)
return model






-- nums_3x3down = {16, 64, 128}
-- nums_1x1 = {0, 0, 0, 0 }
-- nums_3x3up = {16, 64, 128}
-- cur = nil
-- local act = nn.LeakyReLU
-- conv_num = 16
-- cur_depth = nil

-- model = nn.Sequential()
-- model_tmp = model


-- input_depth = net_input_depth
-- print(input_depth)
-- for i = 1,#nums_3x3down do
      
--         local deeper = nn.Sequential()
--         local skip = nn.Sequential()
        
--         model_tmp:add((deeper))

--         -- skip:add(conv(input_depth, nums_1x1[i], 1,1))
--         -- skip:add(bn(nums_1x1[i]))
--         -- skip:add(act(nil, nil, true))
        
        
        
--         deeper:add(conv(input_depth, nums_3x3down[i], 3,2))
--         deeper:add(bn(nums_3x3down[i]))
--         deeper:add(act(nil, nil, true))

--         deeper:add(conv(nums_3x3down[i], nums_3x3down[i], 3,1))
--         deeper:add(bn(nums_3x3down[i]))
--         deeper:add(act(nil, nil, true))



--         deeper_main = nn.Sequential()

--         -- k = nil
--         if i == #nums_3x3down  then
--             k = nums_3x3down[i]
--         else
--             deeper:add(deeper_main)
--             k = nums_3x3up[i+1]
--         end

--         deeper:add(nn.SpatialUpSamplingNearest(2))

--         -- deeper:add(conv(input_depth, nums_3x3[i], 1,1))
--         -- deeper:add(bn(nums_1x1[i]))
--         -- deeper:add(act(nil, nil, true))

        
--         model_tmp:add(conv(nums_1x1[i] +  k, nums_3x3up[i], 3,1))
--         model_tmp:add(bn(nums_3x3up[i]))
--         model_tmp:add(act(nil, nil, true))
        
--         input_depth = nums_3x3down[i]
--         model_tmp = deeper_main
-- end
-- model:add(conv(nums_3x3up[1], 3, 1,1))

-- print (model)
-- return model