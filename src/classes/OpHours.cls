public class OpHours {
    public string hours;
    
    public Map<integer, Session> sessionMap = new Map<integer, Session>();

	//
	// Constructor
	//    
    public OpHours() {
    	hours = '';
    }
    
    //
    // Properties
    //
    public void setHours(string ophrs) {
    	hours = ophrs;
        processSessions();
    }
    
    public string getHours() {
    	return hours;
    }

    
    // Function to turn the Services DB-format open hours text string into an SObject
    // Services DB format is a 224 char string split into 7 blocks of 32 chars (one block per day of week)
    // These blocks of 32 chars can be split further into blocks of four chars.
    // Each block of four chars represents a single session (1-4 per day, open or close times)
    // e.g. 09001700XXXXXXXXXXXXXXXXXXXXXXXX means that on this particular day:
    // -- session one opens at 9am and closes at 5pm
    // -- there are no further sessions (2-4 are blank)
    private void processSessions() {
        string serviceHours = '';
        
        // Get the long service hours string
        serviceHours = hours;
        
        // If the service hours string is the wrong length (224 chars) or null, it is malformed
        // so skip gracefully out of this function and return blank sessions
        if ((serviceHours == null) || (serviceHours.length() <> 224))
            return;

        string hold_text;
        string s1o,s2o,s3o,s4o,s1c,s2c,s3c,s4c,dayow; // a string for every open/close session and its day of week
        
        integer pos = 0;
        
        for (Integer i = 0; i < 7; i++) {
            hold_text = serviceHours.substring(pos*32,(pos*32)+32);
            
            s1o = hold_text.substring(0,4);
            s1c = hold_text.substring(4,8);
            s2o = hold_text.substring(8,12);
            s2c = hold_text.substring(12,16);
            s3o = hold_text.substring(16,20);
            s3c = hold_text.substring(20,24);
            s4o = hold_text.substring(24,28);
            s4c = hold_text.substring(28,32);
            
            if (i == 0) {
                dayow = 'Monday';
            } else if (i == 1) {
                dayow = 'Tuesday';
            } else if (i == 2) {
                dayow = 'Wednesday';
            } else if (i == 3) {
                dayow = 'Thursday';
            } else if (i == 4) {
                dayow = 'Friday';
            } else if (i == 5) {
                dayow = 'Saturday';
            } else if (i == 6) {
                dayow = 'Sunday';
            } else {
                dayow = null;
            }
            
            // Format opening sessions
            if (s1o=='XXXX') { s1o='--:--'; }
            else { s1o=s1o.substring(0,2) + ':' +  s1o.substring(2,4); }
            
            if (s2o=='XXXX') { s2o='--:--'; }
            else { s2o=s2o.substring(0,2) + ':' +  s2o.substring(2,4); }
            
            if (s3o=='XXXX') { s3o='--:--'; }
            else { s3o=s3o.substring(0,2) + ':' +  s3o.substring(2,4); }
            
            if (s4o=='XXXX') { s4o='--:--'; }
            else { s4o=s4o.substring(0,2) + ':' +  s4o.substring(2,4); }
            
            // Format closing sessions
            if (s1c=='XXXX') { s1c='--:--'; }
            else { s1c=s1c.substring(0,2) + ':' +  s1c.substring(2,4); }
            
            if (s2c=='XXXX') { s2c='--:--'; }
            else { s2c=s2c.substring(0,2) + ':' +  s2c.substring(2,4); }
            
            if (s3c=='XXXX') { s3c='--:--'; }
            else { s3c=s3c.substring(0,2) + ':' +  s3c.substring(2,4); }
            
            if (s4c=='XXXX') { s4c='--:--'; }
            else { s4c=s4c.substring(0,2) + ':' +  s4c.substring(2,4); }
            
            // add the new session SObject to the output map
            sessionMap.put(i, new Session(dayow, s1o,s1c, s2o,s2c, s3o,s3c, s4o,s4c));
            pos++;
        }
    }
    
    // Return session from particular day (integer 0 - 6 = mon - sun)
    public Session getSession(integer i) {
    	return sessionMap.get(i);
    }
    
    // Return map of service's sessions. key = integer 0 - 6 = mon - sun
    public Map<integer, Session> getSessionMap() {
    	return sessionMap;
    }
    
}