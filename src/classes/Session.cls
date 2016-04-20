// DATA STRUCTURE for a Service's daily sessions
public class Session { 
        public string DayOfWeek      { get; set; } 
        public string Session1Open   { get; set; }
        public string Session1Closed { get; set; }
        public string Session2Open   { get; set; }
        public string Session2Closed { get; set; }
        public string Session3Open   { get; set; } 
        public string Session3Closed { get; set; }
        public string Session4Open   { get; set; }
        public string Session4Closed { get; set; }
        
        public Session(string Day, string S1O, string S1C, string S2O, string S2C,
                                   string S3O, string S3C, string S4O, string S4C) {
            DayOfWeek = Day; 
            Session1Open = S1O; 
            Session2Open = S2O; 
            Session3Open = S3O; 
            Session4Open = S4O;
            
            Session1Closed = S1C; 
            Session2Closed = S2C; 
            Session3Closed = S3C; 
            Session4Closed = S4C;
        }
        
        public Session() {
            DayOfWeek = '0';
            Session1Open = '--:--'; 
            Session2Open = '--:--'; 
            Session3Open = '--:--'; 
            Session4Open = '--:--';
            
            Session1Closed = '--:--'; 
            Session2Closed = '--:--'; 
            Session3Closed = '--:--'; 
            Session4Closed = '--:--';
        }
        
        // If the parameter string doesn't match format [00-24]:[00-59] then return four Xs (ie. a blank)
        private string testFormat(string s) {
            if (!Pattern.matches('[0-2][0-9]:[0-5][0-9]', s))
                return 'XXXX';
            return s;
        }
        
        // Convert an array of seven Session objects into the Service DB op hours string format
        public string format() {
            string tmp = '';
            
            // Check the format of each session string. If badly formatted, set to XXXX (ie. blank)
            Session1Open = testFormat(Session1Open);    Session1Closed = testFormat(Session1Closed);
            Session2Open = testFormat(Session2Open);    Session2Closed = testFormat(Session2Closed);
            Session3Open = testFormat(Session3Open);    Session3Closed = testFormat(Session3Closed);
            Session4Open = testFormat(Session4Open);    Session4Closed = testFormat(Session4Closed);
            
            // Concatenate to Service DB-format string
            tmp =  Session1Open + Session1Closed + Session2Open + Session2Closed;
            tmp += Session3Open + Session3Closed + Session4Open + Session4Closed;
            
            // Remove colons, replace dashes with Xs
            tmp = tmp.replace('-', 'X');
            tmp = tmp.replace(':', '');
            
            return tmp;
        }
        
        public string getVFsession1() {
        	if (Session1Open == '--:--' && Session1Closed == '--:--')
        		return '';
        	return Session1Open + ' to ' + Session1Closed;
        }
        public string getVFsession2() {
        	if (Session2Open == '--:--' && Session2Closed == '--:--')
        		return '';
        	return Session2Open + ' to ' + Session2Closed;
        }
        public string getVFsession3() {
        	if (Session3Open == '--:--' && Session3Closed == '--:--')
        		return '';
        	return Session3Open + ' to ' + Session3Closed;
        }
        public string getVFsession4() {
        	if (Session4Open == '--:--' && Session4Closed == '--:--')
        		return '';
        	return Session4Open + ' to ' + Session4Closed;
        }
} // END DATA STRUCTURE