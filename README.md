# PLAGUE SIMULATOR

## WHAT IS IT ?

This project is a simulation explaining the effects of spread of infectious diseases within a society.

## HOW IT WORKS

The agents move in a pattern that requires them to go back and forth between their homes and their place of work represented by the building at the center of the simulation.  

When the agents are infected, they go to the hospital represented by the building at the top of the simulation.  

You can modify the following parameters to influence the results of the simulation:  
	- Initial population  
	- Chances to relapse (for progressive diseases)  
	- Chances of healing  
	- Advancement per tick: Rate of increase of healing chances per tick representing the medical advance on the defined disease  
	- Probability of infection  
	- Incubation time  
	- Evolutionary disease or not: Agents can be infected even if they have already been cured  
	- Chance to die  
	- Show place: Staining of patches on which agents die due to the disease  
	- Remedy-exists: Possibility of medical advancement on the disease  
	- Draw-walls: Allows you to design obstacles that agents are programmed to avoid  

## HOW TO USE IT

To use this model:  
	1. Set the parameters defined above  
	2. Click on Setup  
	3. To draw obstacles, click on *Draw walls* then use the mouse to draw  
	4. Click on * go * to launch the simulation  
	NB: The simulation stops after 200 ticks  

## EXAMPLES OF USE

Cholera:  
	- Chance of healing: 80  
	- Probability of infection: 15  
	- Incubation time: 30  
	- Progressive disease: No  
	- Chances of dying: 20  
	- Existing cure: Yes  
	- Advancement per tick: 0 (Cure already exists)  

Plague:  
	- Chances to relapse: 75  
	- Chances of healing: Between 0 et 5  
	- Probability of infection: 50  
	- Incubation time: 70  
	- Progressive disease: Yes  
	- Chances of dying: 80  
	- Existing cure: Yes  
	- Advancement per tick: A choice (depends on the period)  

## EXTENDING THE MODEL

To extend this model, we can add more developed patterns for agents to explain places with high risk of contagion.


## RELATED MODELS

Infectious Disease Model: http://www.personal.kent.edu/~mdball/Infectious_Disease_Model.htm  

## CREDITS AND REFERENCES

This model was created as part of a research project at the Faculty of Sciences of the University of Montpellier by Ines Benghezal and Yasmine Khodja.  

A sheet where some results have been noted can be found by following this link: https://docs.google.com/spreadsheets/d/15RGbbegAQTcCgGti3s5_1tIoF_P5tlVo0yC0CMM6yqk/edit?usp=sharing


###  Copyright (c) 2019 Inès Benghezal and Yasmine Khodja. All rights reserved.
