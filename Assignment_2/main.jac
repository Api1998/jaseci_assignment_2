

import {*} with "./graph.jac";

walker create_familytree {
    // creates a familytree from a json file
    has data_file = "family.json";
    has famly_members = [];

    root {
        families = file.load_json(data_file)["families"];
        for family in families {
            spawn here ++> node::family_root(
                id = family["uid"],
                family_name = family["family_name"]
            );
        }
        take-->node::family_root;
    }

    family_root {
        family_id = here.id;
        members = file.load_json(data_file)["members"];
        filtered_members = [];
        for member in members {
            if (member["family_id"] == family_id) {
                filtered_members.list::append(member);
            }
        }
        for member in filtered_members {
            family_member = spawn here +[member]+> node::person(
                id = member["uid"],
                family_id = member["family_id"],
                name = member["name"],
                date_of_birth = member["date_of_birth"],
                profession = member["profession"],
                gender = member["gender"],
                deceased = member["deceased"],
                parents = member["parents"],
                children = member["children"],
                spouse = member["spouse"],
                height = member["height"],
                weight = member["weight"],
                hobbies = member["hobby"] 
            );
            famly_members.list::append(family_member);
        }
    }

    with exit {
        for member_1 in famly_members {
            for member_2 in famly_members {
                if (member_1.id  == member_2.id): continue;
                if (member_1.spouse == member_2.id and member_2.spouse == member_1.id) {
                    member_1 +[married]+> member_2;
                }
                if (member_1.id in member_2.children): member_1 +[child]+> member_2;
            }
        }
    }
}

walker find_coming_birthday {
    // returns the upcoming birthdays of the family
    has max_return = 5;
    has anchor birthday_order = [];


    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (true) {
            here::get_days_to_birthday;
            here::get_age;
            birthday_order.list::append([here.days_to_birthday, here.age, here.name]);

        }
    }
    with exit {
        birthday_order = std.sort_by_col(birthday_order, 0);
        birthday_order = birthday_order[0:max_return];
        std.out(birthday_order);
        report birthday_order;
        }

}
   


walker find_BMI_prime {
    // returns the healthy condition of the family members
    has anchor BMI_prime_List = [];
    has anchor BMI_prime_test = [];


    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (true) {
            here::get_BMI_Prime;
            BMI_prime_List.list::append(here.BMI_Prime);

            if (here.BMI_Prime < 0.74){
                BMI_prime_test.list::append(" ".str::join([here.name," you are in under weight."]));
            }
            if (here.BMI_Prime > 0.74 and here.BMI_Prime < 1){
                BMI_prime_test.list::append(" ".str::join([here.name," you are in normal weight."]));
            }
            if (here.BMI_Prime > 1 and here.BMI_Prime <1.2){
                BMI_prime_test.list::append(" ".str::join([here.name," you are in over weight. Risky!"]));
            }

            if (here.BMI_Prime > 1.2){
                BMI_prime_test.list::append(" ".str::join([here.name," you are in obese weight class. Highly Risky!!!"]));
            }


        }
    }
    with exit {
        std.out(BMI_prime_test);
        report BMI_prime_test;
        }
}

walker find_people_with_similar_hobbies{
    // return the similarity in hobbies of the family
    has data_file = "family.json";

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        members_list = file.load_json(data_file)["members"];
        hobby_list_a = here.hobbies;
        similar_hobby_members =[];
        member_id = here.id;
        for member_a in members_list{
            if (member_a["uid"] == member_id): continue;
            hobby_list_b = member_a["hobby"];
            for hobby in hobby_list_a{
                if (hobby in hobby_list_b){
                    if (member_a["name"] in similar_hobby_members): continue;
                    similar_hobby_members.l::append(member_a["name"]);
                }
            } 
        }
        std.out(similar_hobby_members);
        report similar_hobby_members;
        
    }
}
walker destroy_family_tree{
    root {

    for i in -[married]->: destroy i;
    for i in -[generic]->: destroy i;
    for i in -[child]->: destroy i;
    take -->;
    }
    
}
