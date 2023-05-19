url = 'http://222.29.33.102:37497/api/status';
out = webwrite(url, struct('mode','ACQUIRE'),weboptions('RequestMethod','put','MediaType','application/json'));
url = 'http://222.29.33.102:37497/api/message'
out = webwrite(url, struct('text','ACQBOARD TRIGGER 1 100'),weboptions('RequestMethod','put','MediaType','application/json'))
out = webread('http://222.29.33.102:37497/api/recording')
url = 'http://222.29.33.102:37497/api/processors/110/config'
out = webwrite(url, msg, weboptions('RequestMethod','put','MediaType','application/json'))
out = webwrite(url, struct('text','{"condition_index" : 0,"name" : "face Name","ttl_line" : 2,"trigger_type" : 3}'), weboptions('RequestMethod','put','MediaType','application/json'))
