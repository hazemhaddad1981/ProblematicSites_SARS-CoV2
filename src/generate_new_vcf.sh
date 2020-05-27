# path to alignment as first argument
alignment_path=$1;

# path variables
subset_caution=subset_vcf/problematic_sites_sarsCov2.caution.vcf;
subset_mask=subset_vcf/problematic_sites_sarsCov2.mask.vcf;
compressed_caution=compressed_vcf/problematic_sites_sarsCov2.caution.vcf.gz;
compressed_mask=compressed_vcf/problematic_sites_sarsCov2.mask.vcf.gz;


# generate new vcf
python src/site_list_to_vcf.py
python src/parse_reference_to_vcf.py $alignment_path
python src/parseCDS.py

# sort vcf, put into if statement to prevent accidental deletion
if [ -f problematic_sites_sarsCov2_genes.vcf ]; then
    header_lines=$(grep "#" problematic_sites_sarsCov2_genes.vcf | wc -l);
    body_lines=$((header_lines+1))
    (head -n "$header_lines" problematic_sites_sarsCov2_genes.vcf && tail -n +"$body_lines" problematic_sites_sarsCov2_genes.vcf | sort -k2 -n) > problematic_sites_sarsCov2.vcf
    rm problematic_sites_sarsCov2_genes.vcf
fi

# subset vcfs
egrep -h "#|caution" problematic_sites_sarsCov2.vcf > $subset_caution
egrep -h "#|mask" problematic_sites_sarsCov2.vcf > $subset_mask

# compress vcfs
bgzip -c problematic_sites_sarsCov2.vcf > problematic_sites_sarsCov2.vcf.gz
bgzip -c $subset_caution > $compressed_caution
bgzip -c $subset_mask > $compressed_mask

# tabix index vcfs
tabix compressed_vcf/problematic_sites_sarsCov2.vcf.gz
tabix --csi compressed_vcf/problematic_sites_sarsCov2.vcf.gz

tabix $compressed_caution
tabix --csi $compressed_caution

tabix $compressed_mask
tabix --csi $compressed_mask
