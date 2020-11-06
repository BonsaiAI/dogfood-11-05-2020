# Using the Toolbox

This document covers connecting a Simulink Cartpole model with the platform using the Bonsai3 Simulink Toolbox.

## Prerequisites – Please Complete Beforehand
- [ ]	Install MATLAB and Simulink on your local machine: https://www.mathworks.com/help/install/ug/install-mathworks-software.html
- [ ]	Get the latest copy of the toolbox, bonsai.mltbx from the FileExchange or Add-on Store
- [ ]	Create an Azure account and add a “Bonsai” resource into your Azure Account. 

## Bonsai Required Scripts
Once you have completed the above, download the Cartpole or Moab model from the "examples" tab and open it up locally. It should have several files:

1. **bonsaiConfig.m**
2. **bonsaiTrain.m**
3. **bonsaiAssessData.m**
4. your_model.slx


These files have the below properties: 

1. **bonsaiConfig.m**

**bonsaiConfig.m** requires two pieces of information - your workspace ID and your access key. To grab your workspace ID, first provision a Bonsai application in your Microsoft Azure account. Once it has been created at http://preview.bons.ai, visit "Workspace Settings" under your user profile dropdown. This will have the Workspace ID, and you can also generate an Access Key. Generate an Access Key and copy it in `config.AccessKey`. 

:warning: NOTE: You can only copy an Access Key once! If you you have closed the window once it pops up, generate another and keep it safe somewhere.


The **bonsaiConfig** script contains the BonsaiConfig functions. This is used to setup the connection between your model and the Bonsai platform. Here you describe several key factors:

- **name** - The name of your simulator (you will see this when you connect to Bonsai)
- **url** - Optional. The URL used to connect the Bonsai API service
- **timeout** -- Optional. The value in seconds for a timeout. A default value of 60 seconds is used if this is not explicitly set.
- **workspace** - The workspace value obtained from the Bonsai platform.
- **accessKey** - the access key obtained from the Bonsai platform.
- **outputCSV** - Optional. When running locally, this can be helpful for debugging your model and the Bonsai connection.
- **stateSchema** - *Important.* This is the *order* of the values as they appear in the input parameter of the Bonsai block. Even if you use a Bus as your input the Bonsai block must understand the order of the values. These names must match what is in your inkling code in Bonsai. 
- **actionSchema** - The actions the brain will perform. The names must match what is in your inkling code from Bonsai. Order is important. 
- **configSchema** - The values that the Bonsai brain will send during a training episode. These are used as configuration parameters to initialize the model with different states.

> A note about states: Your model may contain more states than what is in your inkling code for Bonsai. It is OK to have additional states that you send - these are ignored by the platform during execution. However, you must send all states that are required by the inkling code. If you do not, you will receive an error from the platform with an immediate Unregister command.

>A note about schema: the bonsaiConfig script also has action and state schema set from the states and actions which you have configured to the Bonsai block in your simulink model. These enable you to automatically create a brain (inkling) from scratch. You may override these parameters if you wish to do so by uncommenting out the code block aka 'config.stateSchema' and 'config.actionSchema'.


2. **bonsaiTrain.m**

**bonsaiTrain.m** is our script which validates that the model has all the appropriate dependencies in the project folder and begins training. Note that `mdl` defines the model file, and fast restart is turned on. The script checks that all the appropriate configuration is set in **bonsaiConfig.m**. Make sure to run locally once to ensure the Simulink toolbox is hooked up correctly.


3. **bonsaiAssessData.m**

bonsaiAssessData sets the values necessary for a user to initiate assessment of a trained model. 

## Configuring the Bonsai Toolbox

Once you have the three scripts in place, you can configure your model using the Bonsai Simulink Toolbox. These are the fields that you should hook up with your model: 

1.	STATE: State definition describes variables that represent the state of the system at each time step. Examples from HVAC: current temperature, humidity inside and outside the building, desired temperature.[]
2.	ACTION: There should be identifiable actions that an agent can control. E.g. in a simulation of a manufacturing machine, control actions affect whether the part is made correctly.
4.	HALTED: this is a signal to the service that the sim has reached a completion of a loop, not driven by outcomes set during machine teaching, but rather those coming directly from the model.
5.	RESET: this logic restarts the model from the initial configuration 

## Testing your Model

Once you have configured the toolbox and the above into the block integrated with your model, run `bonsaiTrain` from the Matlab console. This will initiate a training session that you must "attach" to a brain. The name of the model will show up in 'Simulators' as "unmanaged".

You should not need to modify any values in the `bonsaiTrain` script, but to help clarify a few areas that happen in the script:

When you are running `bonsaiTrain` locally, you may want to see the model locally running as training is occurring on the platform. However, once you upload your model to the Bonsai server environment you cannot see the model, so it is disabled. If you attempt to render the model in the server environment the connection will likely timeout and training will not start correctly.

The general flow of Bonsai is:

1. Session register
2. Episode start
3. Receive callback with initialization parameters 
4. Send episode step information using the State inputs
5. Receive an Action from Bonsai
6. The Bonsai Action is an input to a subsystem
7. Steps 5 and 6 are repeated until an episode End event or an error occurs
8. Upon an episode End event, the model will close and the Bonsai toolbox will create a new Episode. Steps 2-8 will repeat.

Another area to call out is the *episodeStartCallback* function. Again, it is not necessary to change anything, but the code is present here to understand what is happening under the hood. 

When Bonsai initiates a training session, a callback is fired and handled here. This allows the user to configure their model environment and set parameters to what their model requires. It is also in this command that the user starts their simulation. Some users may choose to pass just the `mdl` to `sim()`w while others have more dynamic SimulationInput requirements, like below:

- Each time you start a new training Episode in Bonsai, the Bonsai brain will send initial start up parameters that can be used to initialize the model to set it to various states. 

## Uploading and Scaling Your Model

Once you have exported your model and validated that it works locally, you can zip the entire contents of the project folder that contains the exported Simulink Model. The below uses the Moab model as an example: 

For example, if your folder structure is:

```
moab
└─── CAD
|    └── ... step files ...   
└─── Images
|    └── ... image files ...      
└─── Scripts_Data
|    └── calcMOI.m
|    └── cor2SpringDamperParams.m   
|    └── MOAB_PARAMS.m  
|    └── runMixer.m
|    └── runMoabLocalLoop.m
|─── bonsaiConfig.m
|─── bonsaiTrain.m
|─── MOAB.slx
|─── readme.md
└─── startup_MOAB.m
```

The file structure above contains all the necessary contents required to run the model. At this point, you only need to zip the parent **moab** folder. Call it moab.zip. Note: these are the required files that _must_ be in your project folder to upload and scale to the platform: 

1. **bonsaiConfig.m**
2. **bonsaiTrain.m**
3. **bonsaiAssessData.m**
4. your_model.slx

Back in the Bonsai dashboard, next to **Simulators**, click the **Add sim** button.

This will open a dialog. Select MathWorks. Select or drag the moab.zip file . Give your simulator a name, then click **Create simulator**. 

After the simulator is created you will see the new simulator appear under the **Simulators** section.

Now click the *Teach* tab. 

In the simulator definition, just after the open brackets, add back the package statement using the name of the simulator you gave during the Add Simulator dialog above.

```
simulator Simulator(action: Action, config: SimConfig): SimState {
	package "<simulator_name_from_upload>"
}
```

Now click **Train**. Since you indicated the package name you do not need to select a simulator from the dropdown like you did when you started locally.

Within a few minutes time you will see several simulators connect to and train your brain. 

## Exporting your model

Once you have successfully trained your AI and you have reached a point of goal satisfaction or reward convergence, you may choose to then 'Export' your brain for use elsewhere, such as on a specific device. To do this, navigate to the 'Train' tab and click "Export Brain". This provides you with a Docker container that can be addressed externally.

>Note: You do not need to export your brain to test the AI that you have trained, necessarily. You may elect to use the 'assessment' feature (aka next to export, select "Start Assessment" on the Train tab) which will test the AI.

## Cartpole Sample Model

The cartpole sample in [samples/cartpole/](samples/cartpole/) contains model and code based on copyrighted example files from The MathWorks, Inc. and is licensed by the terms outlined in [samples/cartpole/XSLA.txt](samples/cartpole/XSLA.txt).

## Microsoft Open Source Code of Conduct

This repository is subject to the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct).
