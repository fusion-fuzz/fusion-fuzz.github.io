union Union { int i; float f; 
 template<> struct PotentiallySealed<int> sealed { }
}
