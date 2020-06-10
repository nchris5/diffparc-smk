
rule all_bedpostx_gpu:
        input:
                mean_s0samples = 'results/Diffusion_7T/{subject}.BedpostX/mean_S0samples.nii.gz',
                merged_f1samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_f1samples.nii.gz',
                merged_f2samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_f2samples.nii.gz',
                merged_f3samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_f3samples.nii.gz',
                merged_ph1samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_ph1samples.nii.gz',
                merged_ph2samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_ph2samples.nii.gz',
                merged_ph3samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_ph3samples.nii.gz',
                merged_th1samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_th1samples.nii.gz',
                merged_th2samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_th2samples.nii.gz',
                merged_th3samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_th3samples.nii.gz'

#Copy 7T Diffusion files to the snakemake results directory so bedpost will subsequently save it there
rule copy_hcp7T_Diffusion:
	input:
		dwi7T_nii = join(config['dwi_preproc_dir'],config['in_dwi_nii']),
                dwi7T_bval = join(config['dwi_preproc_dir'],config['in_dwi_bval']),
                dwi7T_bvec = join(config['dwi_preproc_dir'],config['in_dwi_bvec']),
                dwi7T_grad_dev = join(config['dwi_preproc_dir'],config['in_dwi_grad_dev']),
                dwi7T_mask_nii = join(config['dwi_preproc_dir'],config['in_dwi_mask_nii'])
	output:
		dwi7T_nii_copy = 'results/Diffusion_7T/{subject}/data.nii,gz',
		dwi7T_bval_copy = 'results/Diffusion_7T/{subject}/bvals',
		dwi7T_bvec_copy = 'results/Diffusion_7T/{subject}/bvecs',
		dwi7T_grad_dev_copy = 'results/Diffusion_7T/{subject}/grad_dev.nii.gz',
		dwi7T_mask_nii_copy = 'results/Diffusion_7T/{subject}/nodif_brain_mask.nii.gz'
	shell:
		'cp {input.dwi7T_nii) {output.dwi7T_nii_copy} && '
		'cp {input.dwi7T_bval) {output.dwi7T_bval_copy} && '
		'cp {input.dwi7T_bvec) {output.dwi7T_bvec_copy} && '
		'cp {input.dwi7T_grad_dev) {output.dwi7T_grad_dev_copy} && '
		'cp {input.dwi7T_mask_nii) {output.dwi7T_mask_nii_copy}'

rule perform_bedpostx_gpu:
	input:
		rules.copy_hcp7T_Diffusion.output
	params:
		bedpostx_options = '-n 3 -w 1 -b 1000 -j 1250 -s 25 -model 2 -g',
		bedpostx_gpu_options = '-Q cuda.q -NJOBS 4',
		bedpostx_gpu_exec = 'workflow/binaries/bedpostx_gpu/bin/bedpostx_gpu'
	output:
		mean_s0samples = 'results/Diffusion_7T/{subject}.BedpostX/mean_S0samples.nii.gz',
                merged_f1samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_f1samples.nii.gz',
                merged_f2samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_f2samples.nii.gz',
                merged_f3samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_f3samples.nii.gz',
                merged_ph1samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_ph1samples.nii.gz',
                merged_ph2samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_ph2samples.nii.gz',
                merged_ph3samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_ph3samples.nii.gz',
                merged_th1samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_th1samples.nii.gz',
                merged_th2samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_th2samples.nii.gz',
                merged_th3samples = 'results/Diffusion_7T/{subject}.BedpostX/merged_th3samples.nii.gz'
	threads: 2
	resources:
		mem_mb = 8000,
		time = 360,    #6 hours
		gpus = 1       #1 gpu
	log: 'logs/perform_bedpostx_gpu/{subject}.log'
	shell:
		'{params.bedpostx_gpu_exec} results/Diffusion_7T/{subject} {params.bedpostx_options} {params.bedpostx_gpu_options} &> {log}'
		


