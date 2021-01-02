# Circuit_Recognition_and_Analysis
Circuit diagram is fundamental to electrical and electronics engineering as it provides key information about a system at the drawing board. The aim of this project was to automate the process of solving the circuits (single loop in the first edition). In this project, we adopted an innovative method for the recognition of components, values and structure of a circuit given a hand drawn image in an effort to automate the circuit analysis process.
<br />
<br />
Hand drawn sketches are one of the most common ways of expressing and organizing one’s ideas in a rough manner in the
ideation process of engineering endeavours. In the case of circuit analysis, what if the process of circuit simulation could be
enacted directly from sketches without needing to remake the
sketch in a formalised simulation environment? Recognition
of circuit components and connections in a hand drawn electrical circuit diagram possesses a number of potential applications including circuit simulations, layout planning for circuit
design rendering and human-machine interfacing for circuit
analysis. This project proposes a tool for digitizing hand
drawn sketches of electrical circuit diagrams and recognizing
the components and connections therein so as to be able to analyze common variables associated with circuit analysis such
as mesh currents and node voltages so as to streamline the circuit analysis process and provide a handy tool for validation
of designs. This application also possesses a particular use in
teaching environments where students may simulate their circuit ideas and solutions by directly feeding the proposed system their circuit diagrams without reconstructing their circuit
physically or in a separate simulation environment making the
learning process more streamlined.
<br />
<br />
The methodology employed accurately enables the calculation of a mesh current given a single mesh input image.
Even though some assumptions were made, the code was
written with as much generalization as possible in order for it
to be scalable to multi-mesh circuits. The choice of using convex deficiency as a feature descriptor was made after first using signatures and encountering unpromising results whereby
correlation of test signatures with standard signatures yielded
fluctuating results yielding a high degree of inaccuracy. A
combination of multiple feature descriptors could potentially
yield better result as opposed to single feature descriptors.
The way forward with the project would be to make it applicable to more complex circuit configurations and incoporating
other circuit analysis techniques besides mesh analysis.
<br />
<br />
The original circuit looks like:
![alt text](https://github.com/MursalinLarik/Circuit_Recognition_and_Analysis/blob/main/circuit.jpg)
<br />
The result after the components and digits are recognized:
<br />
![alt text](https://github.com/MursalinLarik/Circuit_Recognition_and_Analysis/blob/main/detected.jpg)
<br />
The components and the values associated with those components are identified and recorded:
<br />
![alt text](https://github.com/MursalinLarik/Circuit_Recognition_and_Analysis/blob/main/identified.jpg)
<br />
Finally, using Ohm's law in the single mesh, the circuit is solved and the value of current in the loop is displayed:
<br />
![alt text](https://github.com/MursalinLarik/Circuit_Recognition_and_Analysis/blob/main/solved.png)
