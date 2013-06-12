/*
var wheelColliderFrontLeft:WheelCollider;
var wheelColliderFrontRight:WheelCollider;
var wheelColliderBackLeft:WheelCollider;
var wheelColliderBackRight:WheelCollider;
var maxTorque=150.0;
var maxBrakeTorque=500.0;
var fullBrakeTorque=5000.0;
var maxSteerAngle=30.0;
var steerStep:float=1.0;

var wheelFrontLeft:Transform;
var wheelFrontRight:Transform;
var wheelBackLeft:Transform;
var wheelBackRight:Transform;

//var guiSpeed:GUIText;
//var guiSpeedPointer:Texture2D;
//var guiSpeedDisplay:Texture2D;
var gearSpeed:int[];

var maxSpeed:float=200.0;
var maxBackwardSpeed:float=40.0;
var currentSpeed:float=0.0;
//var brakeSound:AudioClip;

var x:int;
var y:int;
var z:int;

private var currentGear:int; 
private var oldForwardFriction:float;
private var oldSidewaysFriction:float;
//private var brakeAudioSource:AudioSource;
//private var isPayingBrakeSound:boolean=false;

var slideForwardFriction:float;
var slideSidewaysFriction:float;

function Start() 
{
    rigidbody.centerOfMass = Vector3 (x, y, z);
    oldForwardFriction = wheelColliderFrontRight.forwardFriction.stiffness;
    oldSidewaysFriction = wheelColliderFrontRight.sidewaysFriction.stiffness;
        //brakeAudioSource = gameObject.AddComponent(AudioSource);
        //brakeAudioSource.clip = brakeSound;
        //brakeAudioSource.loop = true;
        //brakeAudioSource.volume = 0.7;
        //brakeAudioSource.volume=0.7;
}


/*
function SetBrakeEffects(PlayEffects:boolean)
{
	if(PlayEffects)
    {
    	if(!isPayingBrakeSound)
        {
        	isPayingBrakeSound=true;
            brakeAudioSource.Play();
            
            GameObject.Find("DustBackLeft").particleEmitter.emit=true;
            GameObject.Find("DustBackRight").particleEmitter.emit=true;
        }
    }
    else
    {
    	isPayingBrakeSound=false;
        brakeAudioSource.Stop();
        
        GameObject.Find("DustBackLeft").particleEmitter.emit=false;
        GameObject.Find("DustBackRight").particleEmitter.emit=false;       
    }
}
*/

/*
function SetFriction(ForwardFriction:float, SidewaysFriction:float)
{
	wheelColliderFrontLeft.forwardFriction.stiffness = ForwardFriction;
    wheelColliderFrontRight.forwardFriction.stiffness = ForwardFriction;
    wheelColliderBackLeft.forwardFriction.stiffness = ForwardFriction;
    wheelColliderBackRight.forwardFriction.stiffness = ForwardFriction;
        
    wheelColliderFrontLeft.sidewaysFriction.stiffness = SidewaysFriction;
    wheelColliderFrontRight.sidewaysFriction.stiffness = SidewaysFriction;
    wheelColliderBackLeft.sidewaysFriction.stiffness = SidewaysFriction;
    wheelColliderBackRight.sidewaysFriction.stiffness = SidewaysFriction;
}

/*
function OnGUI()
{
    var pointerPosition:float = 40.0;
    
    GUI.Box(Rect(0.0, 0.0, 140.0, 140.0), guiSpeedDisplay);
    
    if(currentSpeed > 0)
    {
    	pointerPosition = currentSpeed + 40;
    }
    
    GUIUtility.RotateAroundPivot(pointerPosition, Vector2(70, 70));
	GUI.DrawTexture(Rect(0.0, 0.0, 140.0, 140.0), guiSpeedPointer, ScaleMode.StretchToFill, true, 0);
}
*/

/*
function Update()
{
	setCurrentGear();
	
    RotateWheels();
    SteelWheels();
}


function FullBraking()
{
    if(Input.GetKey("space"))
	{
    	wheelColliderBackLeft.brakeTorque = fullBrakeTorque;
        wheelColliderBackRight.brakeTorque = fullBrakeTorque;
                
        if( (Mathf.Abs(rigidbody.velocity.z) > 1) || (Mathf.Abs(rigidbody.velocity.x) > 1) )
        {
            //SetBrakeEffects(true);
        	SetFriction(slideForwardFriction,slideSidewaysFriction);
        }
        else
        {
            //SetBrakeEffects(false);
        	SetFriction(oldForwardFriction,oldSidewaysFriction);
    	}
    }
    else
	{
        //SetBrakeEffects(false);
        SetFriction(oldForwardFriction,oldSidewaysFriction);
        
        wheelColliderBackLeft.brakeTorque=0;
    	wheelColliderBackRight.brakeTorque=0;
	}
}


function RotateWheels()
{
	wheelFrontLeft.Rotate(wheelColliderFrontLeft.rpm / 60 * 360 * Time.deltaTime,0,0);
    wheelFrontRight.Rotate(wheelColliderFrontRight.rpm / 60 * 360 * Time.deltaTime,0,0);
    wheelBackLeft.Rotate(wheelColliderBackLeft.rpm / 60 * 360 * Time.deltaTime,0,0);
    wheelBackRight.Rotate(wheelColliderBackRight.rpm / 60 * 360 * Time.deltaTime,0,0);
}


function SteelWheels()
{
	wheelFrontLeft.localEulerAngles.y = wheelColliderFrontRight.steerAngle - wheelFrontLeft.localEulerAngles.z;
    wheelFrontRight.localEulerAngles.y = wheelColliderFrontRight.steerAngle - wheelFrontLeft.localEulerAngles.z;
}


function setCurrentGear()
{
    var gearNumber:int;
    
    gearNumber = gearSpeed.length;
    
    for(var i = 0; i < gearNumber; i++)
	{
        if(gearSpeed[i] > currentSpeed)
        {
        	currentGear = i;
            break;
    	}
    }
    
	//GearSound();
}


function GearSound()
{ 
	var tempMinSpeed:float = 0.00;
	var tempMaxSpeed:float = 0.00;
	var currentPitch:float = 0.00;
	
    switch(currentGear)
	{
   		case 0:
                tempMinSpeed = 0.00;
                tempMaxSpeed = gearSpeed[currentGear];
                
                break;
        default:
                tempMinSpeed = gearSpeed[currentGear - 1];
                tempMaxSpeed = gearSpeed[currentGear];
                
                break;
    }
        
	currentPitch = ( ( (Mathf.Abs(currentSpeed) - tempMinSpeed) / (tempMaxSpeed - tempMinSpeed) ) +0.8);
    //audio.pitch = currentSpeed/maxSpeed+1;
}


function FixedUpdate()
{
	FullBraking();
	
    currentSpeed = (Mathf.PI * 2 * wheelColliderFrontLeft.radius) * wheelColliderFrontLeft.rpm * 60 / 1000;
    currentSpeed = Mathf.Round(currentSpeed);
        
    isBraking = ( (currentSpeed > 0 && Input.GetAxis("Vertical") < 0) || (currentSpeed < 0 && Input.GetAxis("Vertical") > 0) );

    //guiSpeed.material.color = Color.green;

    if( !isBraking)
    {
    	wheelColliderFrontLeft.brakeTorque = 0;
        wheelColliderFrontRight.brakeTorque = 0;
            
        //guiSpeed.text = currentSpeed.ToString() + (maxBackwardSpeed * -1).ToString();
            
        if( (currentSpeed < maxSpeed) && (currentSpeed > (maxBackwardSpeed * -1) ) )
        {
        	wheelColliderFrontLeft.motorTorque = maxTorque * Input.GetAxis("Vertical");
            wheelColliderFrontRight.motorTorque = maxTorque * Input.GetAxis("Vertical");
        }
        else
        {
        	wheelColliderFrontLeft.motorTorque = 0;
            wheelColliderFrontRight.motorTorque = 0;
        }
	}
    else
    {
    	wheelColliderFrontLeft.brakeTorque = maxBrakeTorque;
        wheelColliderFrontRight.brakeTorque = maxBrakeTorque;
            
        wheelColliderFrontLeft.motorTorque = 0;
        wheelColliderFrontRight.motorTorque = 0;
    }
        
	wheelColliderFrontLeft.steerAngle = maxSteerAngle * Input.GetAxis("Horizontal");
    wheelColliderFrontRight.steerAngle = maxSteerAngle * Input.GetAxis("Horizontal");
}
*/

var rearWheel1 : WheelCollider;
var rearWheel2 : WheelCollider;
var frontWheel1 : WheelCollider;
var frontWheel2 : WheelCollider;
 
var wheelFL : Transform;
var wheelFR : Transform;
var wheelRL : Transform;
var wheelRR : Transform;
 
var steer_max = 20;
var motor_max = 40;
var brake_max = 100;
var steerSpeed = 20;
 
private var steer = 0;
private var forward = 0;
private var back = 0;
private var brakeRelease = false;
private var motor = 0;
private var brake = 0;
private var reverse = false;
private var speed = 0;


function Start() 
{
	rigidbody.centerOfMass = Vector3(0, -448.3983, 0);
}

  
function FixedUpdate () 
{
	speed = rigidbody.velocity.sqrMagnitude;
	steer = Input.GetAxis("Horizontal");
	forward = Mathf.Clamp(Input.GetAxis("Vertical"), 0, 1);
	backward = -1 * Mathf.Clamp(Input.GetAxis("Vertical"), -1, 0);
 
	if(speed == 0 && forward == 0 && backward == 0) 
	{
		brakeRelease = true;
	}
 
	if(speed == 0 && brakeRelease) 
	{
		if(backward > 0) 
		{ 
			reverse = true; 
		}
		
		if(forward > 0) 
		{ 
			reverse = false; 
		}
	}
 
	if(reverse) 
	{
		motor = -1 * backward;
		brake = forward;
	} 
	else 
	{
		motor = forward;
		brake = backward;
	}
	
	if (brake > 0 ) 
	{ 
		brakeRelease = false; 
	};
 
	rearWheel1.motorTorque = motor_max * motor;
	rearWheel2.motorTorque = motor_max * motor;
	rearWheel1.brakeTorque = brake_max * brake;
	rearWheel2.brakeTorque = brake_max * brake;
 
	if ( steer == 0 && frontWheel1.steerAngle != 0) 
	{
		if (Mathf.Abs(frontWheel1.steerAngle) <= (steerSpeed * Time.deltaTime)) 
		{
			frontWheel1.steerAngle = 0;
		}
 		else if (frontWheel1.steerAngle > 0) 
			{
				frontWheel1.steerAngle = frontWheel1.steerAngle - (steerSpeed * Time.deltaTime);
			} 
			else 		
			{
				frontWheel1.steerAngle = frontWheel1.steerAngle + (steerSpeed * Time.deltaTime);
			}
		} 
		else 
		{
		frontWheel1.steerAngle = frontWheel1.steerAngle + (steer * steerSpeed * Time.deltaTime);

		if (frontWheel1.steerAngle > steer_max) 
		{ 
			frontWheel1.steerAngle = steer_max; 
		}
		
		if (frontWheel1.steerAngle < -1 * steer_max) 
		{ 
			frontWheel1.steerAngle = -1 * steer_max; 
		}
	}

	frontWheel2.steerAngle = frontWheel1.steerAngle;
	wheelFL.localEulerAngles.y = frontWheel1.steerAngle;
	wheelFR.localEulerAngles.y = frontWheel2.steerAngle;
 
	wheelFR.Rotate(0, 0, frontWheel1.rpm * -6 * Time.deltaTime);
	wheelFL.Rotate(0, 0, frontWheel2.rpm * -6 * Time.deltaTime);
	wheelRR.Rotate(0, 0, rearWheel1.rpm * -6 * Time.deltaTime);
	wheelRL.Rotate(0, 0, rearWheel2.rpm * -6 * Time.deltaTime);
}