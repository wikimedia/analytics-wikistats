#!/bin/bash

# add blacklisted category to exclude.csv
# format: url wiki|top category|category to be pruned (use underscore for spaces)
data=/a/dammit.lt/pagecounts/categorized/data

cat > $data/exclude.csv << "EOF"
en.wikipedia.org|Medicine|Alternative medicine
en.wikipedia.org|Medicine|Medicine in society
en.wikipedia.org|Medicine|Medicine stubs
en.wikipedia.org|Medicine|Medicine portal
en.wikipedia.org|Medicine|Traditional medicine
en.wikipedia.org|Medicine|Veterinary medicine
en.wikipedia.org|Medicine|Centenarians
en.wikipedia.org|Medicine|Animal diseases
en.wikipedia.org|Medicine|*stubs
en.wikipedia.org|Medicine|People with*
en.wikipedia.org|Medicine|People by*
en.wikipedia.org|Medicine|Deaths from*
en.wikipedia.org|Medicine|*deaths by*
en.wikipedia.org|Medicine|*deaths in*
en.wikipedia.org|Medicine|*deaths by*
en.wikipedia.org|Medicine|*medicine in*
en.wikipedia.org|Medicine|*by country
en.wikipedia.org|Medicine|*by nationality
en.wikipedia.org|Medicine|*by region
en.wikipedia.org|Medicine|Orthography
en.wikipedia.org|Medicine|*in fiction
en.wikipedia.org|Medicine|*organizations*
en.wikipedia.org|Medicine|Xenophobia
en.wikipedia.org|Medicine|*fictional*
en.wikipedia.org|Medicine|*pornography*
en.wikipedia.org|Medicine|Phytopathology
en.wikipedia.org|Medicine|Funerals
en.wikipedia.org|Medicine|Ambulance services
en.wikipedia.org|Medicine|*services in*
en.wikipedia.org|Medicine|Human voice
en.wikipedia.org|Medicine|Novels by*
en.wikipedia.org|Medicine|Wellfare*
en.wikipedia.org|Medicine|Sexual health
en.wikipedia.org|Medicine|*ists*
en.wikipedia.org|Medicine|*cians*
en.wikipedia.org|Medicine|*sports
en.wikipedia.org|Medicine|*sport
en.wikipedia.org|Medicine|*culture
en.wikipedia.org|Medicine|*policy
en.wikipedia.org|Medicine|*politics
en.wikipedia.org|Medicine|*people
en.wikipedia.org|Medicine|BDSM
en.wikipedia.org|Medicine|*schools
en.wikipedia.org|Medicine|Youth rights
en.wikipedia.org|Medicine|People convicted of*
en.wikipedia.org|Medicine|Welfare*
en.wikipedia.org|Medicine|Auditory*
en.wikipedia.org|Medicine|Alcohol*
en.wikipedia.org|Medicine|Men and sexuality
en.wikipedia.org|Medicine|Boy bands
en.wikipedia.org|Medicine|Rites*
en.wikipedia.org|Medicine|Adolescence
en.wikipedia.org|Medicine|Secondary education
en.wikipedia.org|Medicine|Mind
en.wikipedia.org|Medicine|*executed by*
en.wikipedia.org|Medicine|Doping cases*
en.wikipedia.org|Medicine|Pharmaceutics*
en.wikipedia.org|Medicine|Natural environment based therapies
en.wikipedia.org|Medicine|*academics*
en.wikipedia.org|Medicine|*researchers*
en.wikipedia.org|Medicine|* law
en.wikipedia.org|Medicine|Suicide*
en.wikipedia.org|Medicine|Human habitats
en.wikipedia.org|Medicine|Privacy
en.wikipedia.org|Medicine|Social work
en.wikipedia.org|Medicine|Abuse
en.wikipedia.org|Medicine|War
en.wikipedia.org|Medicine|Thriller*
en.wikipedia.org|Medicine|Horror*
en.wikipedia.org|Medicine|Abuse*
en.wikipedia.org|Medicine|*survivors*
en.wikipedia.org|Medicine|Deafness
en.wikipedia.org|Medicine|Problem solving
en.wikipedia.org|Medicine|Physical education
en.wikipedia.org|Medicine|Physical exercise
en.wikipedia.org|Medicine|Cruelty
en.wikipedia.org|Medicine|Abortion by*
en.wikipedia.org|Medicine|Abortion in*
en.wikipedia.org|Medicine|Celibacy
en.wikipedia.org|Medicine|* music
en.wikipedia.org|Medicine|Conflict
en.wikipedia.org|Medicine|Perception
en.wikipedia.org|Medicine|* art
en.wikipedia.org|Medicine|Navigation
en.wikipedia.org|Medicine|Melancholia
en.wikipedia.org|Medicine|Tobacco
en.wikipedia.org|Medicine|Fear
en.wikipedia.org|Medicine|Aggression
en.wikipedia.org|Medicine|Psychopathology
en.wikipedia.org|Medicine|Psychoanalytic*

en.wikipedia.org|Medicine|Diets
en.wikipedia.org|Medicine|*deities
en.wikipedia.org|Medicine|*eroticism
en.wikipedia.org|Medicine|Vandalism
en.wikipedia.org|Medicine|Memory
en.wikipedia.org|Medicine|Color
en.wikipedia.org|Medicine|Opium Wars
en.wikipedia.org|Medicine|Spas
en.wikipedia.org|Medicine|*gods

en.wikipedia.org|Africa|.*African-American.*
en.wikipedia.org|Africa|.*Ancient Rome.*
en.wikipedia.org|Africa|.*Arab.*
en.wikipedia.org|Africa|.*British empire.*
en.wikipedia.org|Africa|.*Christian.*
en.wikipedia.org|Africa|.*English colonial empire.*
en.wikipedia.org|Africa|.*Jew.*
en.wikipedia.org|Africa|.*Mediterranean.*
en.wikipedia.org|Africa|.*Middle East.*
en.wikipedia.org|Africa|.*Muslim.*
en.wikipedia.org|Africa|.*Ottoman empire.*
en.wikipedia.org|Africa|African diaspora
en.wikipedia.org|Africa|African diaspora history
en.wikipedia.org|Africa|Afro-Eurasia
en.wikipedia.org|Africa|French language
en.wikipedia.org|Africa|Korean War
en.wikipedia.org|Africa|People of African descent
en.wikipedia.org|Africa|Spanish civil war
en.wikipedia.org|Africa|Spanish language
en.wikipedia.org|Africa|War on Terror
en.wikipedia.org|Africa|World War I
en.wikipedia.org|Africa|World War II
en.wikipedia.org|Africa|Zombies

en.wikipedia.org|World_War_II|Aftermath of World War II
fr.wikipedia.org|Seconde_Guerre_mondiale|Ville titulaire de la croix de guerre 1939-1945 


fr.wikipedia.org|Afrique|Acteur afro-américaine
fr.wikipedia.org|Afrique|Ancien empire en Afrique
fr.wikipedia.org|Afrique|Austronésien
fr.wikipedia.org|Afrique|Culture afro-américaine
fr.wikipedia.org|Afrique|Diaspora africaine
fr.wikipedia.org|Afrique|Espagne
fr.wikipedia.org|Afrique|France
fr.wikipedia.org|Afrique|Langue anglaise
fr.wikipedia.org|Afrique|Langue française
fr.wikipedia.org|Afrique|Monde arabe
fr.wikipedia.org|Afrique|Musicien afro-américaine
fr.wikipedia.org|Afrique|Musique noire américaine
it.wikipedia.org|Africa|Diaspora africana
it.wikipedia.org|Africa|Medioriente
it.wikipedia.org|Africa|Seconda guerra mondiale
EOF

less $data/exclude.csv
