#standdir.sh
#Make directories use a standard name

NEW=(accounting_and_finance
ancient_history
animal_production_systems
applied_information_technology
aviation
biology
business_management_and_enterprise
career_and_enterprise
chemistry
children_family_and_the_community
chinese_second_language
computer_science
dance
design
drama
earth_and_environmental_science
economics
engineering_studies
english
english_as_an_additional_languagedialect
food_science_and_technology
french
geography
german
health_studies
human_biology
indonesian_second_language
integrated_science
italian
japanese_second_language
literature
marine_and_maritime_studies_formerly_technology
materials_design_and_technology
mathematics_methods
mathematics_specialist
media_production_and_analysis
modern_history
music
outdoor_education
philosophy_and_ethics
physical_education_studies
physics
plant_production_systems
politics_and_law
psychology
religion_and_life
visual_arts)

OLD=(accounting-and-finance
ancient-history
animal-production-systems
applied-information-technology
aviation
biological-sciences
business-management-and-enterprise
career-and-enterprise
chemistry
children-family-and-the-community
chinese-second-language
computer-science
dance
design
drama
earth-and-environmental-science
economics
engineering-studies
english
english-as-an-additional-languagedialect
food-science-and-technology
french
geography
german
health-studies
human-biological-science
indonesian-second-language
integrated-science
italian
japanese-second-language
literature
marine-and-maritime-studies
materials-design-and-technology
mathematics
mathematics-specialist
media-production-and-analysis
modern-history
music
outdoor-education
philosophy-and-ethics
physical-education-studies
physics
plant-production-systems
politics-and-law
psychology
religion-and-life
end-page)

OLD_DRAFT=(Accounting_Finance
Ancient_History
Animal_Prod_Systems
Applied_Info_Tech
null
Biological_Sciences
Business_Management_and_Enterprise
Career_and_Enterprise
Chemistry
Children_Family_and_the_Community
Chinese_Second_Language
Computer_Science
Dance
Design
Drama
Earth_and_Environmental_Science
Economics
Engineering_Studies
English
English_as_an_Additional_Language_Dialect
Food_Science_and_Technology
French
Geography
German
Health_Studies
Human_Biological_Science
Indonesian_Second_Language
Integrated_Science
Italian
Japanese_Second_Language
null
Marine_and_Maritime_Technology
Materials_Design_and_Technology
Mathematics
Mathematics_Specialist
Media_Production_and_Analysis
Modern_History
Music
Outdoor_Education
Philosophy_and_Ethics
Physical_Education_Studies
Physics
Plant_Production_Systems+
Politics_and_Law
Psychology
Religion_and_Life
Visual_Arts)

CURRICULUM_COUNCIL=(Accounting_Finance
Ancient_History
Animal_Production_Systems
Applied_Information_Technology
Aviation
Biological_Sciences
Business_Management_and_Enterprise
Career_and_Enterprise
Chemistry
Children_Family_and_the_Community
Chinese_Second_Language
Computer_Science
Dance
Design
Drama
Earth_and_Environmental_Science
Economics
Engineering_Studies
English
English_as_an_Additional_Language
Food_Science_and_Technology
French
Geography
German
Health_Studies
Human_Biological_Science
Indonesian_Second_Language
Integrated_Science
Italian
Japanese_Second_Language
Literature
Marine_and_Maritime
Materials_Design_and_Technology
Mathematics
Mathematics_Specialist
Media_Production_and_Analysis
Modern_History
Music
Outdoor_Education
Philosophy_and_Ethics
Physical_Education_Studies
Physics
Plant_Production_Systems
Politics_and_Law
Psychology
Religion_and_Life
Visual_Arts)

#WACE
#mathematics -> mathematics methods (? or apps?)

#WACE draft
#Aboriginal_Intercultural_Studies -> *
#Aboriginal_Languages -> *
#Automotive_Engineering_and_Technology -> *
#Building_and_Construction -> *

# mkdir $(ls -1v ../ATAR/ | sed 's|-|_|g; s|_past_atar.*||g; /[.]/d')

WACE_DRAFT=WACE_DRAFT_CC
CC=WACE_old_09-10_CC
SCSA=WACE_old_09-15
WACE1516=WACE_old_arc
ATAR_SAMPLE=ATAR_sample
ATAR=ATAR

for course in $(find "$ATAR" -type d); do
    t=${course//-past-atar*/}
    mv "$course" "${t//-/_}"
done

base="$(shell cygpath -w "$PWD/..")"
i=0
for course in ${NEW[@]}; do
    if [ "${OLD[$i]}" != "null" ]; then
        mv "$WACE1516/${OLD[$i]}" "$WACE1516/$course"
    fi
    if [ "${CURRICULUM_COUNCIL[$i]}" != "null" ]; then
        mv "$CC/${CURRICULUM_COUNCIL[$i]}" "$CC/$course"
        mv "$SCSA/${CURRICULUM_COUNCIL[$i]}" "$SCSA/$course"
    fi
    if [ "${OLD_DRAFT[$i]}" != "null" ]; then
        mv "$WACE_DRAFT/${OLD_DRAFT[$i]}" "$WACE_DRAFT/$course"
    fi
    ((i++))
done
mv "$ATAR/mathematics" "$ATAR/mathematics_methods"
mv "$CC/mathematics" "$CC/mathematics_methods"
mv "$SCSA/mathematics" "$SCSA/mathematics_methods"
mv "$WACE1516/mathematics" "$WACE1516/mathematics_methods"

mv "$ATAR_SAMPLE/english2" "$ATAR_SAMPLE/english"
mv "$ATAR_SAMPLE/english-as-an-additional-language-or-dialect" "$ATAR_SAMPLE/english_as_an_additional_languagedialect"
mv "$ATAR_SAMPLE/marine-and-maritime-studies" "$ATAR_SAMPLE/marine_and_maritime_studies_formerly_technology"

for course in $(find "$ATAR_SAMPLE" -type d); do
    mv "$course" "${course//-/_}"
done