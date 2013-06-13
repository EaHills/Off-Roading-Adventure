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
	//rigidbody.centerOfMass = Vector3(0, -448.3983, 0);
}

  
function FixedUpdate () 
{
	speed = rigidbody.velocity.sqrMagnitude;
	steer = Input.GetAxis("Horizontal");
	forward = Mathf.Clamp(Input.GetAxis("Vertical"), 0, 1);
	
	rearWheel1.motorTorque = forward * 10;
	rearWheel2.motorTorque = forward * 10;
	frontWheel1.steerAngle = steer * 20;
	frontWheel2.steerAngle = steer * 20;
	
//	backward = -1 * Mathf.Clamp(Input.GetAxis("Vertical"), -1, 0);
// 
//	if(speed == 0 && forward == 0 && backward == 0) 
//	{
//		brakeRelease = true;
//	}
// 
//	if(speed == 0 && brakeRelease) 
//	{
//		if(backward > 0) 
//		{ 
//			reverse = true; 
//		}
//		
//		if(forward > 0) 
//		{ 
//			reverse = false; 
//		}
//	}
// 
//	if(reverse) 
//	{
//		motor = -1 * backward;
//		brake = forward;
//	} 
//	else 
//	{
//		motor = forward;
//		brake = backward;
//	}
//	
//	if (brake > 0 ) 
//	{ 
//		brakeRelease = false; 
//	};
// 
//	rearWheel1.motorTorque = motor_max * motor;
//	rearWheel2.motorTorque = motor_max * motor;
//	rearWheel1.brakeTorque = brake_max * brake;
//	rearWheel2.brakeTorque = brake_max * brake;
// 
//	if ( steer == 0 && frontWheel1.steerAngle != 0) 
//	{
//		if (Mathf.Abs(frontWheel1.steerAngle) <= (steerSpeed * Time.deltaTime)) 
//		{
//			frontWheel1.steerAngle = 0;
//		}
// 		else if (frontWheel1.steerAngle > 0) 
//			{
//				frontWheel1.steerAngle = frontWheel1.steerAngle - (steerSpeed * Time.deltaTime);
//			} 
//			else 		
//			{
//				frontWheel1.steerAngle = frontWheel1.steerAngle + (steerSpeed * Time.deltaTime);
//			}
//		} 
//		else 
//		{
//		frontWheel1.steerAngle = frontWheel1.steerAngle + (steer * steerSpeed * Time.deltaTime);
//
//		if (frontWheel1.steerAngle > steer_max) 
//		{ 
//			frontWheel1.steerAngle = steer_max; 
//		}
//		
//		if (frontWheel1.steerAngle < -1 * steer_max) 
//		{ 
//			frontWheel1.steerAngle = -1 * steer_max; 
//		}
//	}
//
//	frontWheel2.steerAngle = frontWheel1.steerAngle;
//	wheelFL.localEulerAngles.y = frontWheel1.steerAngle;
//	wheelFR.localEulerAngles.y = frontWheel2.steerAngle;
// 
//	wheelFR.Rotate(0, 0, frontWheel1.rpm * -6 * Time.deltaTime);
//	wheelFL.Rotate(0, 0, frontWheel2.rpm * -6 * Time.deltaTime);
//	wheelRR.Rotate(0, 0, rearWheel1.rpm * -6 * Time.deltaTime);
//	wheelRL.Rotate(0, 0, rearWheel2.rpm * -6 * Time.deltaTime);
}