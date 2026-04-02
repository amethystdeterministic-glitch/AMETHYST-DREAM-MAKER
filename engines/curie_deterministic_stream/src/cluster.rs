pub fn is_new_cluster(signature: &String, clusters: &Vec<String>) -> bool {
    !clusters.contains(signature)
}
