-- wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/computerCirix.lua && computerCirix
while(true) do
  if(component.redstone.getInput(3) > 0) then         -- Recieved request to assemble
    component.assembler.start()                       -- Assemble
    while(component.assembler.status() == "busy") do  -- Wait until finished
      
    end
    component.redstone.setOutput(3,1)                 -- Report that assembling finished
    while(component.redstone.getInput(3) > 0) do      -- Wait until confirmation

    end
    component.redstone.setOutput(3,0)                 -- Stop reporting
  end
end
