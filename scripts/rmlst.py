import glob, os, sys
from snakemake import shell

sample        = snakemake.wildcards.sample
assembly_file = snakemake.input.assembly
outdir        = snakemake.params.outdir
output_json   = snakemake.output.rmlst_json
#output_tab    = snakemake.output.rmlst_tab
threads       = snakemake.threads
log           = snakemake.log[0]

with open(log, "w") as f:
    sys.stderr = sys.stdout = f
    uri = 'http://rest.pubmlst.org/db/pubmlst_rmlst_seqdef_kiosk/schemes/1/sequence'
    #    with open(args.file, 'r') as x: 
    #        fasta = x.read()
    fasta = open(assembly_file, 'r').read()
    payload = '{"base64":true,"details":true,"sequence":"' + base64.b64encode(fasta.encode()).decode() + '"}'
    response = requests.post(uri, data=payload)
    if response.status_code == requests.codes.ok:
        data = response.json()
        try: 
            data['taxon_prediction']
        except KeyError:
            print("No match")
            sys.exit(0)
        for match in data['taxon_prediction']:
                print("Rank: " + match['rank'])
                print("Taxon:" + match['taxon'])
                print("Support:" + str(match['support']) + "%")
                print("Taxonomy" + match['taxonomy'] + "\n")
    
    else:
        print(response.text)
    
    with open(output_json, 'w') as outhandle_output_json:
        outhandle_output_json.write(json.dumps(data, indent=4))
